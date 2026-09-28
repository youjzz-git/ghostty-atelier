// Crayon watercolor paper for Ghostty 1.3.1 (native alpha blending).
//
// The terminal background becomes a sheet of watercolor paper. A few washes
// are laid in from the edges in the theme's own pigments: the cursor color,
// the selection color and the palette's bright yellow. Pigment gathers at the
// rim of each wash as it dries, settles into the paper tooth, and glazes where
// two washes overlap. The middle of the sheet stays mostly clean for text.
// Two crayon strokes run around opposite corners inside the window padding,
// broken by the paper grain the way wax skips over tooth.
//
// Light themes (crayon-peach, crayon-lemon, crayon-lilac, crayon-seaside) use
// the washes like real watercolor, as transparent filters over the paper.
// Dark themes (crayon-starry, crayon-cocoa, crayon-moss, crayon-berry) are
// colored paper, and the pigment lies on top of it like soft pastel.
//
// Nothing depends on iTime, so the shader runs with custom-shader-animation = false.
// Ghostty on macOS puts fragCoord's origin at the top left; the layout below
// uses a y-up position so "up" means up.
// iChannel0 holds terminal pixels only, not the desktop behind the window.
// Samples are never displaced, glyphs and colored cells pass through, and the
// output keeps premultiplied alpha.

const float WASH_STRENGTH = 1.0;    // depth of the watercolor washes
const float GRAIN_STRENGTH = 1.0;   // paper tooth and sizing
const float CRAYON_STRENGTH = 1.0;  // the two crayon strokes in the padding
// Device pixels per point. Textures are sized in points so the paper looks
// the same on any window; 2.0 matches Retina displays.
const float DEVICE_SCALE = 2.0;

const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);

float gaussian(float x, float width) {
    float p = x / width;
    return exp(-p * p);
}

float roundedBox(vec2 p, vec2 halfSize, float radius) {
    vec2 q = abs(p) - halfSize + vec2(radius);
    return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius;
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

float fbm(vec2 p) {
    const mat2 turn = mat2(0.8, -0.6, 0.6, 0.8);
    float sum = 0.0;
    float amp = 0.5;
    for (int i = 0; i < 4; i++) {
        sum += amp * valueNoise(p);
        p = turn * p * 2.03 + 17.1;
        amp *= 0.5;
    }
    return sum / 0.9375;
}

// How much each channel a pigment absorbs, scaled so every pigment has the
// same depth and only its hue differs.
vec3 absorbance(vec3 pigment) {
    vec3 filt = pigment / max(max(pigment.r, max(pigment.g, pigment.b)), 1e-3);
    vec3 a = -log(max(filt, vec3(0.04)));
    return a / max(max(a.r, max(a.g, a.b)), 1e-3);
}

// The same pigment as a light, slightly deepened pastel for dark paper.
vec3 pastel(vec3 pigment) {
    vec3 filt = pigment / max(max(pigment.r, max(pigment.g, pigment.b)), 1e-3);
    return pow(filt, vec3(1.8));
}

// Pigment density of one wash at pt (points). soft = 0 dries to a hard edge
// with a dark rim; soft = 1 is wet-in-wet and fades out without one.
float wash(vec2 pt, vec2 center, float radius, float seed, float soft, float tooth) {
    float shape = fbm(pt / (radius * 0.45) + seed);
    float ripple = valueNoise(pt / (radius * 0.07) + seed * 3.1) - 0.5;
    float sd = length(pt - center) - radius * (0.62 + 0.45 * shape + 0.06 * ripple);

    float edgeWidth = mix(2.5, 0.35 * radius, soft);
    float body = 1.0 - smoothstep(-edgeWidth, 0.3 * edgeWidth, sd);
    // Pigment migrates toward the edge as the wash dries, leaving the inside
    // paler, with a thin dark line where the water stopped.
    float inside = mix(0.42, 0.78, smoothstep(-0.55 * radius, 0.0, sd));
    float rim = gaussian(sd + 1.8, 2.2) * 0.55 * (1.0 - soft);
    float density = body * inside + rim;

    density *= 0.70 + 0.60 * fbm(pt / (radius * 0.16) + seed * 7.0);
    // Granulation: pigment settles into the hollows of the paper.
    density *= 0.72 + 0.56 * (1.0 - tooth);
    return density;
}

// Wax coverage of one crayon stroke that runs along the frame line sd = 0 and
// tapers out as along approaches length.
float crayon(float sd, float along, float length, float tooth, float streak) {
    float pressure = smoothstep(length, 0.6 * length, along);
    float halfWidth = 2.2 * (0.6 + 0.4 * pressure);
    float profile = 1.0 - abs(sd) / halfWidth;
    float wax = profile * 0.8 + (tooth - 0.5) * 1.0 + (streak - 0.5) * 0.8 + 0.30 * pressure - 0.18;
    return smoothstep(0.05, 0.28, wax) * step(0.0, profile) * smoothstep(0.0, 0.2, pressure);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 res = max(iResolution.xy, vec2(1.0));
    vec4 src = texture(iChannel0, fragCoord / res);
    fragColor = src;
    if (src.a <= 0.001) return;

    // How much of this pixel is bare paper. The gate is soft, so antialiased
    // glyph edges take the new paper color in proportion to their uncovered
    // part. Glyph cores, ANSI colors, selections and images stay untouched.
    vec3 straight = src.rgb / max(src.a, 0.001);
    vec3 delta = abs(straight - iBackgroundColor);
    float paper = 1.0 - smoothstep(0.0, 0.35, max(max(delta.r, delta.g), delta.b));
    paper *= 1.0 - smoothstep(0.90, 0.995, src.a);
    if (paper <= 0.001) return;

    vec2 pos = vec2(fragCoord.x, res.y - fragCoord.y);
    vec2 size = res / DEVICE_SCALE;           // window in points
    vec2 pt = pos / DEVICE_SCALE;
    float m = min(size.x, size.y);

    vec3 base = iBackgroundColor;
    float lightPaper = smoothstep(0.35, 0.60, dot(base, LUMA));

    // Cold-press paper: fine tooth plus faint uneven sizing.
    float tooth = fbm(pt / 2.6);
    float sizing = fbm(pt / 180.0 + 3.7);

    // Ghostty 1.3.1 hands the selection foreground to iSelectionBackgroundColor
    // (verified in a live window), so take whichever selection color is not
    // the text color. This keeps working once the uniforms are fixed.
    vec3 pigA = iCursorColor;
    vec3 selA = iSelectionBackgroundColor;
    vec3 selB = iSelectionForegroundColor;
    vec3 pigB = distance(selA, iForegroundColor) >= distance(selB, iForegroundColor) ? selA : selB;
    vec3 pigC = iPalette[11];

    // Washes come in from the edges and corners; overlaps glaze.
    float a1 = wash(pt, vec2(0.06, 0.94) * size, 0.50 * m, 1.3, 0.0, tooth);
    float b1 = wash(pt, vec2(0.97, 0.55) * size, 0.34 * m, 5.9, 0.0, tooth);
    float c1 = wash(pt, vec2(0.34, 0.00) * size, 0.38 * m, 9.2, 1.0, tooth);
    float b2 = wash(pt, vec2(0.62, 1.04) * size, 0.24 * m, 12.7, 0.0, tooth);
    float a2 = wash(pt, vec2(1.00, 0.02) * size, 0.30 * m, 15.1, 1.0, tooth);
    float dA = (a1 + a2 * 0.8) * WASH_STRENGTH;
    float dB = (b1 + b2) * WASH_STRENGTH;
    float dC = c1 * 0.8 * WASH_STRENGTH;

    // Light paper: the washes are transparent filters and multiply.
    vec3 absorbed = absorbance(pigA) * dA + absorbance(pigB) * dB + absorbance(pigC) * dC;
    vec3 onLight = base * exp(-0.42 * absorbed);
    onLight *= 1.0 + ((tooth - 0.5) * 0.06 + (sizing - 0.5) * 0.04) * GRAIN_STRENGTH;

    // Dark paper: the pigment lies on top as a soft pastel layer.
    vec3 onDark = base;
    onDark = mix(onDark, pastel(pigA), clamp(dA * 0.24, 0.0, 1.0));
    onDark = mix(onDark, pastel(pigB), clamp(dB * 0.24, 0.0, 1.0));
    onDark = mix(onDark, pastel(pigC), clamp(dC * 0.12, 0.0, 1.0));
    onDark += ((tooth - 0.5) * 0.030 + (sizing - 0.5) * 0.020) * GRAIN_STRENGTH;

    vec3 sheet = mix(onDark, onLight, lightPaper);

    // Crayon: a stroke around the upper left corner in the cursor color and
    // one around the lower right in the palette's bright magenta, each gone
    // over twice by hand, drawn inside the window padding.
    vec2 inset = vec2(5.5, 4.0);
    float frame = roundedBox(pt - size * 0.5, size * 0.5 - inset, 10.0);
    frame += (valueNoise(pt / 38.0) - 0.5) * 1.4 + (valueNoise(pt / 9.0 + 4.0) - 0.5) * 0.5;
    // The second pass wanders a little off the first.
    float second = frame + 0.9 + (valueNoise(pt / 70.0 + 21.0) - 0.5) * 2.0;
    float vertical = step(min(size.y - pt.y, pt.y), min(pt.x, size.x - pt.x));
    float streak = mix(valueNoise(vec2(pt.x / 7.0, pt.y / 0.8)),
                       valueNoise(vec2(pt.x / 0.8, pt.y / 7.0)), vertical);
    float streak2 = mix(valueNoise(vec2(pt.x / 6.0, pt.y / 0.7) + 50.0),
                        valueNoise(vec2(pt.x / 0.7, pt.y / 6.0) + 50.0), vertical);
    float waxTooth = fbm(pt / 1.1 + 8.0);
    float reach = 0.34 * m;
    float alongA = pt.x + (size.y - pt.y);
    float alongB = (size.x - pt.x) + pt.y;
    float strokeA = max(crayon(frame, alongA, reach, waxTooth, streak),
                        crayon(second, alongA, 0.75 * reach, waxTooth, streak2) * 0.85);
    float strokeB = max(crayon(frame + 0.5, alongB, 1.1 * reach, waxTooth, streak),
                        crayon(second + 0.5, alongB, 0.8 * reach, waxTooth, streak2) * 0.85);
    vec3 waxA = mix(pigA, pigA * 0.82, lightPaper);
    vec3 waxB = mix(iPalette[13], iPalette[13] * 0.9, lightPaper);
    sheet = mix(sheet, waxA, strokeA * 0.92 * CRAYON_STRENGTH);
    sheet = mix(sheet, waxB, strokeB * 0.92 * CRAYON_STRENGTH);
    float wax = max(strokeA, strokeB) * CRAYON_STRENGTH;

    // Pigment and wax read as surface, so they gain a little opacity over the
    // configured background-opacity; crayon is nearly opaque.
    float pigment = clamp((dA + dB + dC) * 0.5, 0.0, 1.0);
    float outAlpha = clamp(src.a + paper * ((1.0 - src.a) * (0.10 * pigment + 0.85 * wax)), 0.0, 1.0);
    vec3 color = clamp(straight + paper * (sheet - base), vec3(0.0), vec3(1.0));
    fragColor = vec4(color * outAlpha, outAlpha);
}
