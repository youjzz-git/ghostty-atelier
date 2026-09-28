# 洇 · Ink bleed

[中文](ink-bleed.md) · [Back to the overview](../README.en.md)

**洇** (yīn) is the way ink spreads when it lands on wet paper.

This is a set of shaders for [Ghostty](https://ghostty.org). The terminal no longer sits on a solid slab of color. The window is clear glass, and the text paints its own background: under every passage a pool of ink bleeds out, following the shape of the words, with pigment granulating near the edge and a darker line where the water dried. Colored text lends a little of its color to the ink around it. Where there is no text the window stays almost fully transparent and the wallpaper shows through untouched, so the composition changes all the time: as you type and scroll, the ink moves with the words.

![Preview](ink-bleed/hero.png)

![The ink follows new text as it appears](ink-bleed/bleed.gif)

The backdrop behind the window in these previews is a procedurally generated sky. It looks better over your own wallpaper.

## Install

Install everything as described in the [overview](../README.en.md#install), or copy just this set from the repository root:

```sh
mkdir -p ~/.config/ghostty/shaders ~/.config/ghostty/themes
cp shaders/bleed-measure.glsl shaders/bleed-spread.glsl shaders/bleed.glsl ~/.config/ghostty/shaders/
cp themes/ink-ultramarine ~/.config/ghostty/themes/
```

Then add this to `~/.config/ghostty/config`:

```ini
theme = ink-ultramarine
background-opacity = 0.8
window-padding-x = 12

# all three shaders are required, in this order
custom-shader = ~/.config/ghostty/shaders/bleed-measure.glsl
custom-shader = ~/.config/ghostty/shaders/bleed-spread.glsl
custom-shader = ~/.config/ghostty/shaders/bleed.glsl
custom-shader-animation = false
```

Save and press `⌘⇧,` to reload the config. If you only changed the contents of a shader file, a reload may show nothing new; open a new window to see it.

`background-opacity` has to be below 1. The shader tells text from background by alpha: background pixels carry exactly this value, glyph pixels are fully opaque. At 1 nothing can be told apart.

## How it works

The obvious way to ask "is there text near this pixel?" is to let every pixel sample a ring around itself. The first version did exactly that, 96 samples per pixel. It looked right but cost too much GPU, and the reason is on Ghostty's side: in 1.3.1, as soon as any custom shader is loaded, a focused window is redrawn at the display refresh rate, which is 120 frames per second on a ProMotion screen, and `custom-shader-animation = false` does not stop it. Whatever a shader costs per frame is multiplied by 120.

So the work is split into three passes over a coarse grid of cells a dozen or so pixels wide:

1. `bleed-measure.glsl` counts how much "ink" each cell holds (glyphs, or cells whose color differs from the background) and the average color of that ink.
2. `bleed-spread.glsl` blurs those values across the grid with a Gaussian, which gives the density of the ink after it has spread.
3. `bleed.glsl` interpolates the density at every pixel from the four nearest cells, decides whether the pixel is ink or glass, and colors it.

The grid data has to live somewhere. Ghostty passes a single window-sized image between its shaders and offers no other buffer. The left and right padding never contains text, though, so the first two passes write the grid into the outermost 12 pixels on each side of the window, and the third pass restores those strips to the background color when it is done. Those pixels sit next to each other, so the GPU handles them in batches, and the first two passes only do real work on about one percent of the screen. This is also why `window-padding-x` must not be smaller than 12.

Coloring: the theme's background color is the ink. The ink drifts slowly between neighboring hues at constant lightness, so text contrast does not change. A paper grain is laid into it, a darker water line runs just inside the edge, and the edge itself wavers a little. If the text nearby is colored, the ink leans toward that color: bluish under a blue link, warmer under a yellow warning. Glyphs, cells with their own background color, the selection and images are passed through unchanged.

## Performance

Measured on an M2 Max with Ghostty 1.3.1, test window 1488×1864 pixels kept in front. The numbers are the share of GPU time used by the Ghostty process, computed from the per-process `accumulatedGPUTime` in IOKit. "Spinner" simulates a command-line tool redrawing a loading animation ten times a second; "full-screen output" keeps printing colored text into the terminal.

| Setup | Spinner | Full-screen output |
|---|---|---|
| No shader | about 1% | about 11% |
| One shader that does nothing | about 10% | — |
| First version: 96 samples per pixel | about 57% | about 60% |
| Current three-pass version | about 25–30% | about 27–30% |

The second row shows that Ghostty's continuous redraw has a fixed cost of its own, whatever the shader does. Larger windows and more text on screen cost more; a full-screen window is roughly double the table. Worth keeping in mind on battery.

## Tunables

The parameters are constants at the top of the shader files. Changes take effect in a new window.

| Constant | File | Default | Effect |
|---|---|---|---|
| `REACH` | bleed-spread | 36.0 | How far the ink bleeds out from the text, in points |
| `INK_OPACITY` | bleed | 0.88 | Opacity inside the pool of ink |
| `GLASS_OPACITY` | bleed | 0.10 | Opacity where there is no text; 0 makes it fully clear |
| `EDGE_LINE` | bleed | 1.0 | Strength of the dark water line along the edge |
| `WORD_COLOR` | bleed | 1.0 | How much the ink borrows from colored text |
| `HUE_DRIFT` | bleed | 0.06 | How far the ink drifts between neighboring hues, in turns |
| `BRUSH` | bleed | 1.0 | Repaints palette 8 highlight backgrounds as a light brushstroke; 0 leaves them as they are |
| `STRIP` | all three | 12 | Width of the data strip at the window edge, in pixels; must match in all files |
| `DEVICE_SCALE` | bleed-spread, bleed | 2.0 | Pixels per point; 2 for Retina displays |

## Another ink

The ink is the theme's `background`. `themes/ink-ultramarine` is a violet-leaning ultramarine with pearl white text; the other ANSI colors are cornflower, champagne, leaf green, rose, lavender and emerald, all kept soft enough to be comfortable yet bright enough on the dark ink.

Other themes work too, as long as the background is dark and `background-opacity` is below 1. An ink-black, ochre or deep green background gives you a different ink.

## With Claude Code

Claude Code's `dark-ansi` theme puts a gray background (ANSI bright black, palette 8) behind the messages you send. With `BRUSH` on, `bleed.glsl` recognizes that background and repaints the gray block as a light stroke of ink, slightly brighter than its surroundings, with a horizontal brush texture and dry-brush breaks at the ends and along the edges. Any other program that uses palette 8 as a background color gets the same treatment.

One detail of the detection: when Ghostty draws a cell with a background color, it first lays down the window background and then the cell color, both at `background-opacity`. The result is palette 8 mixed with about one sixth of the background color, at an alpha of about 0.95, and the shader matches that actual color.

## Limitations

Only tested with Ghostty 1.3.1 on macOS; not tried on Linux.

Ink detection treats every pixel that differs from the background as "text", so interfaces with large colored areas, such as the bars in htop or the vim status line, get ink around them too. That usually looks fine, but the colored blocks themselves do not turn into ink.

`DEVICE_SCALE` is set to 2 for Retina screens. On a non-Retina external display the paper grain and the bleed look twice as large; everything still works. The data strip takes only 12 pixels, so 12 pt of padding is enough at 1×.

With split panes, each pane computes its own ink.
