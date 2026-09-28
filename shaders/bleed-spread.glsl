// 洇 · ink bleed, pass 2 of 3: blurs the coarse ink cells into a soft bleed.
// Works only on the storage pixels; see bleed-measure.glsl.

const float REACH = 36.0;           // points the ink can bleed past the text
const float DEVICE_SCALE = 2.0;     // device pixels per point (Retina)
const int STRIP = 12;               // match the other passes

int cellSize(vec2 res) {
    return max(12, int(ceil(sqrt(res.x / float(2 * STRIP)))) + 1);
}

// Where cell c is stored, in pixel centers.
vec2 storage(ivec2 c, ivec2 cells, vec2 res) {
    int n = c.y * cells.x + c.x;
    int slot = n % (2 * STRIP);
    int x = slot < STRIP ? slot : int(res.x) - 2 * STRIP + slot;
    return vec2(float(x), float(n / (2 * STRIP))) + 0.5;
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

    // Gaussian over the cells within REACH.
    float reachPx = REACH * DEVICE_SCALE;
    float sigma = reachPx / 2.5;
    int r = int(ceil(reachPx / float(g)));
    float inkSum = 0.0;
    float weightSum = 0.0;
    vec3 wordSum = vec3(0.0);
    for (int dy = -8; dy <= 8; dy++) {
        if (abs(dy) > r) continue;
        for (int dx = -8; dx <= 8; dx++) {
            if (abs(dx) > r) continue;
            ivec2 c = cell + ivec2(dx, dy);
            if (c.x < 0 || c.y < 0 || c.x >= cells.x || c.y >= cells.y) continue;
            float d = length(vec2(dx, dy)) * float(g);
            if (d > reachPx) continue;
            float w = exp(-0.5 * d * d / (sigma * sigma));
            vec4 s = texture(iChannel0, storage(c, cells, res) / res);
            float ink = s.a * s.a;
            inkSum += w * ink;
            weightSum += w;
            wordSum += w * ink * s.rgb;
        }
    }
    float density = inkSum / max(weightSum, 1e-4);
    vec3 words = inkSum > 1e-5 ? wordSum / inkSum : iBackgroundColor;
    fragColor = vec4(clamp(words, 0.0, 1.0), sqrt(density));
}
