// 洇 · ink bleed for Ghostty 1.3.1 (native alpha blending).
//
// The window is clear glass over the wallpaper, and the terminal's own text
// paints its background. Every passage sits in a pool of watercolor that
// bleeds out from the letters into the glass, the way ink spreads into wet
// paper: the pool follows the shape of the text, gathers a darker line where
// it dries, granulates, marbles slowly between neighboring hues, and takes a
// little of the color of the words inside it. Where there is no text the
// painting behind shows almost untouched, so every screen is a different
// composition.
//
// The theme's background color is the ink (themes/ink-ultramarine).
//
// This is the last of three passes: bleed-measure.glsl and bleed-spread.glsl
// must run first (custom-shader lines in that order). They leave the blurred
// ink measure of every coarse cell in the storage strips at the window's side
// edges; this pass interpolates it at every pixel, paints, and turns the
// strips back into background. See bleed-measure.glsl for why and how.
//
// Nothing depends on iTime, so the shader runs with custom-shader-animation = false.
// iChannel0 holds terminal pixels only, not the desktop behind the window.
// Samples are never displaced, glyphs and colored cells pass through, and the
// output keeps premultiplied alpha.

const int STRIP = 12;               // storage pixels at each side; match the other passes
const float INK_OPACITY = 0.88;     // opacity inside a pool
const float GLASS_OPACITY = 0.10;   // opacity where there is no text
const float EDGE_LINE = 1.0;        // the darker line where a pool dried
const float WORD_COLOR = 1.0;       // how much a pool takes the hue of its words
const float HUE_DRIFT = 0.06;       // marbling between neighboring hues, in turns
const float BRUSH = 1.0;            // palette 8 highlights as a brush stroke; 0 leaves them gray
// Device pixels per point; 2.0 matches Retina displays.
const float DEVICE_SCALE = 2.0;

const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);

float gaussian(float x, float width) {
    float p = x / width;
    return exp(-p * p);
}

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float valueNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = hash12(i);
    float b = hash12(i + vec2(1.0, 0.0));
    float c = hash12(i + vec2(0.0, 1.0));
    float d = hash12(i + vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Rotates a color's hue around the gray axis.
vec3 hueRotate(vec3 c, float turns) {
    float a = turns * 6.28318;
    vec3 k = vec3(0.57735);
    float cosA = cos(a);
    return c * cosA + cross(k, c) * sin(a) + k * dot(k, c) * (1.0 - cosA);
}

// How far a straight (unpremultiplied) color is from the background.
float offBackground(vec3 c) {
    vec3 d = abs(c - iBackgroundColor);
    return max(max(d.r, d.g), d.b);
}

int cellSize(vec2 res) {
    return max(12, int(ceil(sqrt(res.x / float(2 * STRIP)))) + 1);
}

// The blurred ink measure of cell c: density, and the ink color in color.
float readCell(ivec2 c, ivec2 cells, vec2 res, out vec3 color) {
    c = clamp(c, ivec2(0), cells - 1);
    int n = c.y * cells.x + c.x;
    int slot = n % (2 * STRIP);
    int x = slot < STRIP ? slot : int(res.x) - 2 * STRIP + slot;
    vec4 s = texture(iChannel0, (vec2(float(x), float(n / (2 * STRIP))) + 0.5) / res);
    color = s.rgb;
    return s.a * s.a;
}

// Whether the pixel at p (device pixels) is bare background, so outside any
// highlight. The storage strips are padding and count as bare.
bool bareAt(vec2 p, vec2 res) {
    if (p.x < float(STRIP) || p.x >= res.x - float(STRIP)) return true;
    vec4 s = texture(iChannel0, p / res);
    vec3 off = abs(s.rgb - iBackgroundColor * s.a);
    return max(max(off.r, off.g), off.b) < 0.05 && s.a < 0.9;
}

// Whether the pixel at p (device pixels) is a highlight cell background.
bool isHighlight(vec2 p, vec3 highlight, vec2 res) {
    vec4 s = texture(iChannel0, p / res);
    vec3 d = abs(s.rgb / max(s.a, 0.001) - highlight);
    return max(max(d.r, d.g), d.b) < 0.06 && s.a < 0.975;
}

// Distance in device pixels from p to the first bare pixel in direction dir,
// up to far: four coarse probes, then three halvings of the step it fell in.
float runTo(vec2 p, vec2 dir, float far, vec2 res) {
    float lo = 0.0;
    float hi = far;
    bool found = false;
    for (int k = 1; k <= 4; k++) {
        float t = far * float(k) * 0.25;
        if (bareAt(p + dir * t, res)) {
            hi = t;
            found = true;
            break;
        }
        lo = t;
    }
    if (!found) return far;
    for (int k = 0; k < 3; k++) {
        float mid = 0.5 * (lo + hi);
        if (bareAt(p + dir * mid, res)) hi = mid; else lo = mid;
    }
    return 0.5 * (lo + hi);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 res = max(iResolution.xy, vec2(1.0));
    vec4 src = texture(iChannel0, fragCoord / res);
    fragColor = src;
    vec3 ink = iBackgroundColor;

    // The storage strips are padding, so they are bare background. Other
    // pixels keep their own colors; how much of them is bare background
    // decides how much of the new color they take, so antialiased glyph edges
    // blend and glyph cores, colored cells, selections and images stay
    // untouched.
    bool strip = fragCoord.x < float(STRIP) || fragCoord.x >= res.x - float(STRIP);
    vec3 straight = strip ? ink : src.rgb / max(src.a, 0.001);
    float bare = 1.0;
    // Claude Code's dark-ansi theme lays the user's messages on palette 8.
    // Those cells, and the antialiased glyph edges on them, are repainted as
    // a lighter brush stroke of the ink instead of a flat gray block.
    // A cell background is drawn over the window background, both at
    // background-opacity, so palette 8 arrives mixed with about a sixth of
    // the background and at alpha near 0.95 (measured in Ghostty 1.3.1).
    vec3 highlight = mix(iBackgroundColor, iPalette[8], 0.83);
    float brushed = 0.0;
    if (!strip) {
        bare = (1.0 - smoothstep(0.0, 0.35, offBackground(straight))) * (1.0 - smoothstep(0.90, 0.995, src.a));
        vec3 dh = abs(straight - highlight);
        brushed = (1.0 - smoothstep(0.04, 0.10, max(max(dh.r, dh.g), dh.b)))
                * (1.0 - smoothstep(0.975, 0.998, src.a)) * BRUSH;
        // The antialiased edges of gray text can take the same color for a
        // pixel or two; a highlight cell has more of it a few pixels away.
        if (brushed > 0.0 && !(isHighlight(fragCoord + vec2(4.0, 0.0), highlight, res)
                            || isHighlight(fragCoord - vec2(4.0, 0.0), highlight, res)
                            || isHighlight(fragCoord + vec2(0.0, 4.0), highlight, res)
                            || isHighlight(fragCoord - vec2(0.0, 4.0), highlight, res))) {
            brushed = 0.0;
        }
        if (bare <= 0.001 && brushed <= 0.001) return;
    }

    vec2 pt = fragCoord / DEVICE_SCALE;

    // Interpolate the ink measure between the four surrounding cell centers.
    int g = cellSize(res);
    ivec2 cells = ivec2(ceil(res / float(g)));
    vec2 u = fragCoord / float(g) - 0.5;
    ivec2 c = ivec2(floor(u));
    vec2 f = u - floor(u);
    vec3 c00, c10, c01, c11;
    float d00 = readCell(c, cells, res, c00);
    float d10 = readCell(c + ivec2(1, 0), cells, res, c10);
    float d01 = readCell(c + ivec2(0, 1), cells, res, c01);
    float d11 = readCell(c + ivec2(1, 1), cells, res, c11);
    vec4 wq = vec4((1.0 - f.x) * (1.0 - f.y), f.x * (1.0 - f.y), (1.0 - f.x) * f.y, f.x * f.y);
    vec4 dq = vec4(d00, d10, d01, d11);
    float density = dot(wq, dq);
    float inkSum = max(density, 1e-4);
    vec3 wordSum = wq.x * dq.x * c00 + wq.y * dq.y * c10 + wq.z * dq.z * c01 + wq.w * dq.w * c11;

    // The pool: its edge wanders with the wet paper, pigment granules give it
    // a fine grain, and pigment gathers into a darker line just inside it.
    float wander = (0.65 * valueNoise(pt / 22.0 + 3.1) + 0.35 * valueNoise(pt / 9.0 + 8.3) - 0.5) * 0.030;
    float granules = (hash12(fragCoord) - 0.5) * 0.022;
    // Only near ink, so stray grain does not speckle the clear glass.
    float wet = density + (wander + granules) * smoothstep(0.001, 0.012, density);
    float pool = smoothstep(0.008, 0.040, wet);

    // Bare glass: nothing more to paint, and at this opacity paper texture
    // would not show anyway.
    if (pool <= 0.0 && brushed <= 0.0) {
        vec3 glass = straight;
        float glassAlpha = strip ? GLASS_OPACITY : mix(src.a, GLASS_OPACITY, bare);
        fragColor = vec4(glass * glassAlpha, glassAlpha);
        return;
    }
    float line = gaussian(wet - 0.036, 0.012) * pool * EDGE_LINE;

    // Ink color: the background hue marbles in slow bands at level
    // brightness, granulates in the paper tooth, and leans toward the hue of
    // the words it carries when they are colored.
    float phase = 0.0021 * pt.x + 0.0016 * pt.y + 0.35 * sin(pt.x / 97.0 + 1.3 * sin(pt.y / 131.0));
    vec3 body = max(hueRotate(ink, HUE_DRIFT * sin(6.28318 * phase)), vec3(0.0));
    body *= dot(ink, LUMA) / max(dot(body, LUMA), 1e-4);

    vec3 words = wordSum / max(inkSum, 1e-4);
    float wordsMax = max(words.r, max(words.g, words.b));
    float chroma = (wordsMax - min(words.r, min(words.g, words.b))) / max(wordsMax, 1e-3);
    vec3 wordTint = words / max(dot(words, LUMA), 1e-3) * dot(body, LUMA);
    body = mix(body, wordTint, 0.30 * WORD_COLOR * smoothstep(0.15, 0.5, chroma) * pool);

    float tooth = valueNoise(pt / 2.3);
    float bloom = valueNoise(pt / 30.0 + 7.7);
    body *= 0.88 + 0.16 * tooth + 0.10 * (bloom - 0.5);
    body *= 1.0 - 0.38 * line;

    float alpha = mix(GLASS_OPACITY, INK_OPACITY, pool);
    alpha = min(alpha + 0.08 * line, 1.0);

    // The brush stroke: a lighter, slightly bluer glaze with bristle streaks
    // along the stroke. Near its ends and its upper and lower edges the brush
    // runs dry, so the pool shows through between the bristles.
    vec3 stroke = body;
    float strokeAlpha = alpha;
    if (brushed > 0.0) {
        float along = min(runTo(fragCoord, vec2(-1.0, 0.0), 70.0, res),
                          runTo(fragCoord, vec2(1.0, 0.0), 70.0, res));
        float across = min(runTo(fragCoord, vec2(0.0, -1.0), 18.0, res),
                           runTo(fragCoord, vec2(0.0, 1.0), 18.0, res));
        // Each bristle streak runs out at its own distance from the end, and
        // some drop out along the upper and lower edges.
        float bristle = valueNoise(vec2(pt.x / 45.0, pt.y / 0.9) + 11.0);
        float fine = valueNoise(vec2(pt.x / 7.0, pt.y / 0.45) + 23.0);
        float runsOut = 0.12 + 0.75 * (0.75 * bristle + 0.25 * fine);
        float cover = smoothstep(runsOut - 0.06, runsOut + 0.06, along / 70.0)
                    * smoothstep(0.7 * runsOut - 0.06, 0.7 * runsOut + 0.06, across / 18.0);
        vec3 cornflower = iPalette[12] / max(max(iPalette[12].r, max(iPalette[12].g, iPalette[12].b)), 1e-3);
        vec3 glaze = mix(body, cornflower, 0.30) * (0.92 + 0.14 * bristle + 0.06 * fine);
        stroke = mix(body, glaze, cover);
        strokeAlpha = mix(alpha, 0.94, cover);
    }

    vec3 color = clamp(straight + bare * (body - ink) + brushed * (stroke - highlight), vec3(0.0), vec3(1.0));
    float outAlpha = strip ? alpha : clamp(src.a + bare * (alpha - src.a) + brushed * (strokeAlpha - src.a), 0.0, 1.0);
    fragColor = vec4(color * outAlpha, outAlpha);
}
