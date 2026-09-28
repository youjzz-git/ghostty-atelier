// 洇 · ink bleed, pass 1 of 3: measures how much ink each coarse cell holds.
//
// Load the three passes in order:
//   custom-shader = .../bleed-measure.glsl
//   custom-shader = .../bleed-spread.glsl
//   custom-shader = .../bleed.glsl
//
// Ghostty 1.3.1 re-renders custom shaders every frame (120 fps on ProMotion)
// even with custom-shader-animation = false, so the bleed is not worked out
// at every pixel. The window is divided into coarse cells, and the ink
// measure of each cell is kept in the outermost STRIP pixels at the left and
// right window edges, inside the padding where no text is ever drawn. These
// storage pixels sit together, so the GPU runs the heavy work on a few
// percent of the screen in tight groups. Pass 1 writes each cell's ink
// coverage and average ink color, pass 2 (bleed-spread.glsl) blurs the cells
// into a soft bleed, and pass 3 (bleed.glsl) interpolates it at every pixel,
// paints, and restores the storage pixels to background.
//
// A storage pixel holds rgb = average ink color (straight) and
// a = sqrt(ink density). Everything else passes through untouched.

const int STRIP = 12;               // storage pixels at each side; fits 12 pt padding at 1x and 2x

float offBackground(vec3 c) {
    vec3 d = abs(c - iBackgroundColor);
    return max(max(d.r, d.g), d.b);
}

// Coarse cell size in device pixels, large enough that every cell fits in
// the two strips. Must match the other passes.
int cellSize(vec2 res) {
    return max(12, int(ceil(sqrt(res.x / float(2 * STRIP)))) + 1);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 res = max(iResolution.xy, vec2(1.0));
    fragColor = texture(iChannel0, fragCoord / res);

    int width = int(res.x);
    ivec2 p = ivec2(fragCoord);
    int slot = p.x < STRIP ? p.x : (p.x >= width - STRIP ? p.x - (width - 2 * STRIP) : -1);
    if (slot < 0) return;

    int g = cellSize(res);
    ivec2 cells = ivec2(ceil(res / float(g)));
    int n = p.y * 2 * STRIP + slot;
    if (n >= cells.x * cells.y) return;
    ivec2 cell = ivec2(n % cells.x, n / cells.x);

    // Coverage of the cell: reads at texel corners every two pixels, so each
    // averages a 2 x 2 block and together they cover the whole cell.
    vec2 origin = vec2(cell * g);
    vec3 bg = iBackgroundColor;
    float inkSum = 0.0;
    vec3 wordSum = vec3(0.0);
    float count = 0.0;
    for (int j = 1; j < 16; j += 2) {
        if (j >= g) break;
        for (int i = 1; i < 16; i += 2) {
            if (i >= g) break;
            vec4 s = texture(iChannel0, (origin + vec2(float(i), float(j))) / res);
            vec3 off = abs(s.rgb - bg * s.a);
            float ink = smoothstep(0.06, 0.20, max(max(off.r, off.g), off.b));
            inkSum += ink;
            wordSum += ink * s.rgb / max(s.a, 0.001);
            count += 1.0;
        }
    }
    float density = inkSum / max(count, 1.0);
    vec3 words = inkSum > 1e-4 ? wordSum / inkSum : bg;
    fragColor = vec4(clamp(words, 0.0, 1.0), sqrt(density));
}
