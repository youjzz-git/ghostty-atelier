// Diamond glass for Ghostty 1.3.1 (native alpha blending).
//
// The glass takes its color from the theme background and plays it across the
// window like opal: the hue drifts in slow marbled bands while brightness stays
// level, so text contrast is the same everywhere. Light enters at the upper
// right, where it splits into a soft spectrum, and the glass brightens gently
// toward its edges. Three fixed glints sit on the polished edge, inside the
// window padding where no text is drawn. There are no facet lines.
//
// The theme decides the mood: diamond-opal (violet, magenta, sapphire),
// diamond-ruby (rose, crimson, violet), diamond-sapphire (royal blue, cerulean,
// indigo) and diamond-aqua (sea-glass teal, periwinkle). Their dark twins are
// diamond-amethyst, diamond-garnet, diamond-abyss and diamond-tourmaline.
//
// Nothing depends on iTime, so the shader runs with custom-shader-animation = false.
// Ghostty on macOS puts fragCoord's origin at the top left (verified in a live
// window); the layout below uses a y-up position so "up" means up.
// iChannel0 holds terminal pixels only, not the desktop behind the window.
// Samples are never displaced, glyphs and colored cells pass through, and the
// output keeps premultiplied alpha.

// The opal hue drifts between these two offsets from the background, in turns:
// a little toward green-cyan, further toward blue, violet and rose.
const float HUE_LOW = -0.07;
const float HUE_HIGH = 0.13;
const float SATURATION = 1.30;      // extra color in the glass body
const float EDGE_GLOW = 1.0;        // soft light gathered at the glass edges
const float FIRE_STRENGTH = 1.0;    // spectrum where the light enters
const float GLINT_STRENGTH = 1.0;   // the three glints on the edge

const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);

float gaussian(float x, float width) {
    float p = x / width;
    return exp(-p * p);
}

float roundedBox(vec2 p, vec2 halfSize, float radius) {
    vec2 q = abs(p) - halfSize + vec2(radius);
    return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius;
}

vec3 spectrum(float t) {
    return 0.5 + 0.5 * cos(6.28318 * (t + vec3(0.0, 0.33, 0.67)));
}

// Rotates a color's hue around the gray axis.
vec3 hueRotate(vec3 c, float turns) {
    float a = turns * 6.28318;
    vec3 k = vec3(0.57735);
    float cosA = cos(a);
    return c * cosA + cross(k, c) * sin(a) + k * dot(k, c) * (1.0 - cosA);
}

// A four-point star with short diagonal rays. d is measured in points.
vec3 starGlint(vec2 d, float size) {
    float r = length(d);
    float core = exp(-r * r / (2.4 * size * size));
    float halo = exp(-r / (9.0 * size));
    float rays = exp(-abs(d.y) / 0.50) * exp(-abs(d.x) / (44.0 * size))
               + exp(-abs(d.x) / 0.50) * exp(-abs(d.y) / (32.0 * size));
    vec2 q = vec2(d.x + d.y, d.x - d.y) * 0.70710678;
    float diagonals = exp(-abs(q.y) / 0.40) * exp(-abs(q.x) / (11.0 * size))
                    + exp(-abs(q.x) / 0.40) * exp(-abs(q.y) / (11.0 * size));
    vec3 rayTint = mix(vec3(1.0), spectrum(r / (30.0 * size) + 0.55), 0.30);
    return vec3(1.0) * core * 0.80
         + rayTint * (rays * 0.40 + diagonals * 0.18)
         + vec3(0.88, 0.92, 1.00) * halo * 0.16;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 res = max(iResolution.xy, vec2(1.0));
    vec4 src = texture(iChannel0, fragCoord / res);
    fragColor = src;
    if (src.a <= 0.001) return;

    // How much of this pixel is bare glass. The gate is soft, so antialiased
    // glyph edges take the new glass color in proportion to their uncovered
    // part and no fringe of the old background is left around text.
    // Glyph cores, ANSI colors, selections and images stay untouched.
    vec3 straight = src.rgb / max(src.a, 0.001);
    vec3 delta = abs(straight - iBackgroundColor);
    float distanceToBackground = max(max(delta.r, delta.g), delta.b);
    float glass = 1.0 - smoothstep(0.0, 0.35, distanceToBackground);
    glass *= 1.0 - smoothstep(0.90, 0.995, src.a);
    if (glass <= 0.001) return;

    vec2 pos = vec2(fragCoord.x, res.y - fragCoord.y);
    vec2 p = pos / res;
    float m = min(res.x, res.y);
    // Rough device pixels per point, so hairlines stay hairlines on Retina.
    float px = clamp(m / 1000.0, 1.0, 2.2);

    float edge = max(0.0, -roundedBox(pos - res * 0.5, res * 0.5 - vec2(0.6 * px), 13.0 * px));
    vec2 fromLit = res - pos;
    float litCorner = exp(-length(fromLit) / (0.55 * m));

    // Opal body: the background hue drifts in slow marbled bands, with extra
    // saturation, while brightness is held level. It is a touch brighter where
    // the light enters and a touch deeper at the far corner.
    vec3 base = iBackgroundColor;
    float phase = 0.95 * p.x + 0.60 * p.y
                + 0.22 * sin(3.4 * p.y + 2.1 * p.x + 1.3)
                + 0.12 * sin(5.1 * p.x - 1.2 * p.y + 0.4);
    float drift = mix(HUE_LOW, HUE_HIGH, 0.5 + 0.5 * sin(6.28318 * phase));
    vec3 body = max(hueRotate(base, drift), vec3(0.0));
    body = max(mix(vec3(dot(body, LUMA)), body, SATURATION), vec3(0.0));
    float level = dot(base, LUMA) * (0.90 + 0.35 * litCorner);
    body *= level / max(dot(body, LUMA), 1e-4);

    // The glass edges gather light: a soft inward glow in a pale version of
    // the local hue. No line is drawn.
    vec3 pale = mix(vec3(0.86, 0.92, 1.0), body / max(max(body.r, max(body.g, body.b)), 1e-4), 0.45);
    vec3 edgeGlow = pale * gaussian(edge, 0.10 * m) * (0.022 + 0.045 * litCorner) * EDGE_GLOW;

    // Fire: light entering the upper right corner fans out into a soft
    // spectrum, pastel rather than saturated, carried by a few broad rays
    // with soft edges.
    float fan = atan(fromLit.y, fromLit.x) / 1.5708;
    float reach = length(fromLit);
    float rays = pow(0.5 + 0.5 * cos(6.28318 * (2.6 * fan + 0.08)), 5.0) * 0.65
               + pow(0.5 + 0.5 * cos(6.28318 * (4.1 * fan + 0.31)), 7.0) * 0.45;
    vec3 fire = mix(vec3(1.0), spectrum(0.15 + 0.9 * fan + reach / (0.9 * m)), 0.60)
              * (exp(-reach / (0.26 * m)) * 0.10 + rays * exp(-reach / (0.42 * m)) * 0.045)
              * FIRE_STRENGTH;

    // The polished rim: a hairline glancing reflection on the window edge.
    vec3 rim = vec3(gaussian(edge - 0.60 * px, 0.75 * px),
                    gaussian(edge - 1.05 * px, 0.68 * px),
                    gaussian(edge - 1.50 * px, 0.75 * px))
             * (0.08 + 0.14 * litCorner);

    // Three fixed glints on the edge, inside the padding: a larger one near
    // the lit corner, a small one down the right edge, an echo on the bottom.
    vec3 glints = starGlint((pos - vec2(res.x - 0.13 * m, res.y - 5.0 * px)) / px, 1.0)
                + starGlint((pos - vec2(res.x - 5.0 * px, res.y - 0.22 * m)) / px, 0.50) * 0.80
                + starGlint((pos - vec2(0.16 * m, 4.0 * px)) / px, 0.55) * 0.70;
    glints *= GLINT_STRENGTH;

    vec3 light = edgeGlow + fire + rim + glints;

    // Shift the glass from the flat background to the opal body, then add
    // light. Brighter light also reads as surface, not haze, so it gains a
    // little opacity relative to the configured background-opacity.
    float outAlpha = clamp(src.a + glass * 0.10 * min(dot(light, LUMA), 0.5), 0.0, 1.0);
    vec3 color = clamp(straight + glass * (body - base + light), vec3(0.0), vec3(1.0));
    fragColor = vec4(color * outAlpha, outAlpha);
}
