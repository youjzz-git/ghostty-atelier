# Ghostty Atelier · Ghostty 画室

[中文](README.md) · English

53 themes for [Ghostty](https://ghostty.org). Some use shaders to turn the window into bleeding ink, gem glass or watercolor paper; others put a painting behind the terminal, in cel-shaded, glitch, cyber, retro and cartoon styles; and a set of transparent themes paints only part of the window and leaves the rest as glass, so your wallpaper becomes part of the picture. Every background is drawn by code, stroke by stroke: no photos, no AI-generated images.

![cover](docs/cover.jpg)

## Contents

- [Install](#install)
- [All themes](#all-themes)
- Shader themes: [洇 · Ink bleed](#ink) · [Diamond glass](#diamond) · [Crayon watercolor](#crayon)
- Background themes: [Paintings](#paintings) · [Cel-shaded](#toon) · [Glitch](#glitch) · [Cyber](#cyber) · [Retro](#retro) · [Cartoon](#cartoon)
- Transparent themes: [Glass](#glass) · [Lace](#lace) · [Muse](#muse)
- [Notes](#notes)
- [Layout](#layout)
- [License](#license)

## Install

```sh
git clone https://github.com/youjzz-git/ghostty-atelier.git
cd ghostty-atelier
./install.sh
```

`install.sh` copies `themes/`, `shaders/` and `backgrounds/` into the directories of the same name under `~/.config/ghostty/`. It never touches your config file. Files with the same name are overwritten, so running it again updates everything.

Then pick a theme in `~/.config/ghostty/config`. A background theme needs two or three lines:

```ini
theme = toon-citadel
background-opacity = 0.8
background-opacity-cells = true
```

Shader themes also need their shaders, and transparent themes need `background-opacity = 0.5`; each collection below shows its full config. When you switch to another collection, remove or comment out the previous `custom-shader` lines, or the old shader keeps running.

Press `⌘⇧,` to reload the config. If the background image or shader does not change, open a new window.

## All themes

| # | Theme | Collection | Shader | Background image | Opacity |
|---|---|---|---|---|---|
| 1 | [`ink-ultramarine`](#ink) | 洇 · Ink bleed | `bleed-measure.glsl` + `bleed-spread.glsl` + `bleed.glsl` | — | 0.8 |
| 2 | [`diamond-opal`](#diamond) | Diamond glass | `diamond.glsl` | — | 0.8 |
| 3 | [`diamond-ruby`](#diamond) | Diamond glass | `diamond.glsl` | — | 0.8 |
| 4 | [`diamond-sapphire`](#diamond) | Diamond glass | `diamond.glsl` | — | 0.8 |
| 5 | [`diamond-aqua`](#diamond) | Diamond glass | `diamond.glsl` | — | 0.8 |
| 6 | [`diamond-amethyst`](#diamond) | Diamond glass | `diamond.glsl` | — | 0.8 |
| 7 | [`diamond-garnet`](#diamond) | Diamond glass | `diamond.glsl` | — | 0.8 |
| 8 | [`diamond-abyss`](#diamond) | Diamond glass | `diamond.glsl` | — | 0.8 |
| 9 | [`diamond-tourmaline`](#diamond) | Diamond glass | `diamond.glsl` | — | 0.8 |
| 10 | [`crayon-peach`](#crayon) | Crayon watercolor | `watercolor.glsl` | — | 0.85 |
| 11 | [`crayon-lemon`](#crayon) | Crayon watercolor | `watercolor.glsl` | — | 0.85 |
| 12 | [`crayon-lilac`](#crayon) | Crayon watercolor | `watercolor.glsl` | — | 0.85 |
| 13 | [`crayon-seaside`](#crayon) | Crayon watercolor | `watercolor.glsl` | — | 0.85 |
| 14 | [`crayon-starry`](#crayon) | Crayon watercolor | `watercolor.glsl` | — | 0.85 |
| 15 | [`crayon-cocoa`](#crayon) | Crayon watercolor | `watercolor.glsl` | — | 0.85 |
| 16 | [`crayon-moss`](#crayon) | Crayon watercolor | `watercolor.glsl` | — | 0.85 |
| 17 | [`crayon-berry`](#crayon) | Crayon watercolor | `watercolor.glsl` | — | 0.85 |
| 18 | [`paint-dusk`](#paintings) | Paintings | — | `dusk.jpg` | 0.97 |
| 19 | [`crayon-night`](#paintings) | Paintings | — | `crayon.jpg` | 0.97 |
| 20 | [`ink-moon`](#paintings) | Paintings | — | `ink.jpg` | 0.97 |
| 21 | [`impression-dawn`](#paintings) | Paintings | — | `impression.jpg` | 0.97 |
| 22 | [`scroll-qingming`](#paintings) | Paintings | — | `qingming.jpg` | 0.97 |
| 23 | [`toon-planet`](#toon) | Cel-shaded | — | `toon.jpg` | 0.8 |
| 24 | [`toon-koi`](#toon) | Cel-shaded | — | `koi.jpg` | 0.8 |
| 25 | [`toon-castle`](#toon) | Cel-shaded | — | `castle.jpg` | 0.8 |
| 26 | [`toon-citadel`](#toon) | Cel-shaded | — | `citadel.jpg` | 0.8 |
| 27 | [`toon-leyndell`](#toon) | Cel-shaded | — | `leyndell.jpg` | 0.8 |
| 28 | [`glitch-signal`](#glitch) | Glitch | — | `glitch.jpg` | 0.8 |
| 29 | [`glitch-peony`](#glitch) | Glitch | — | `peony.jpg` | 0.8 |
| 30 | [`glitch-mirage`](#glitch) | Glitch | — | `mirage.jpg` | 0.8 |
| 31 | [`glitch-eclipse`](#glitch) | Glitch | — | `eclipse.jpg` | 0.8 |
| 32 | [`cyber-neon`](#cyber) | Cyber | — | `cyber.jpg` | 0.8 |
| 33 | [`cyber-sakura`](#cyber) | Cyber | — | `sakura.jpg` | 0.8 |
| 34 | [`cyber-skyrail`](#cyber) | Cyber | — | `skyrail.jpg` | 0.8 |
| 35 | [`cyber-skycity`](#cyber) | Cyber | — | `skycity.jpg` | 0.8 |
| 36 | [`retro-seventies`](#retro) | Retro | — | `retro.jpg` | 0.8 |
| 37 | [`retro-flowerpower`](#retro) | Retro | — | `flowerpower.jpg` | 0.8 |
| 38 | [`retro-steampunk`](#retro) | Retro | — | `steampunk.jpg` | 0.8 |
| 39 | [`retro-gramophone`](#retro) | Retro | — | `gramophone.jpg` | 0.8 |
| 40 | [`sticker-pop`](#cartoon) | Cartoon | — | `sticker.jpg` | 0.8 |
| 41 | [`sticker-garden`](#cartoon) | Cartoon | — | `garden.jpg` | 0.8 |
| 42 | [`cartoon-teahouse`](#cartoon) | Cartoon | — | `cafe.jpg` | 0.8 |
| 43 | [`cartoon-laputa`](#cartoon) | Cartoon | — | `laputa.jpg` | 0.8 |
| 44 | [`glass-moongate`](#glass) | Glass | — | `glass-moongate.png` | 0.5 |
| 45 | [`glass-aurora`](#glass) | Glass | — | `glass-aurora.png` | 0.5 |
| 46 | [`glass-rain`](#glass) | Glass | — | `glass-rain.png` | 0.5 |
| 47 | [`lace-cameo`](#lace) | Lace | — | `lace-cameo.png` | 0.5 |
| 48 | [`lace-curtain`](#lace) | Lace | — | `lace-curtain.png` | 0.5 |
| 49 | [`lace-veil`](#lace) | Lace | — | `lace-veil.png` | 0.5 |
| 50 | [`muse-mucha`](#muse) | Muse | — | `muse-mucha.png` | 0.5 |
| 51 | [`muse-klimt`](#muse) | Muse | — | `muse-klimt.png` | 0.5 |
| 52 | [`muse-cover`](#muse) | Muse | — | `muse-cover.png` | 0.5 |
| 53 | [`muse-mondrian`](#muse) | Muse | — | `muse-mondrian.png` | 0.5 |

<a id="ink"></a>

## 洇 · Ink bleed

The window is clear glass and the text paints its own background: a pool of ink bleeds out under every passage, with granulation and a dried water line at the edge, while empty areas stay almost fully transparent. How it works, performance numbers and tunables are in [docs/ink-bleed.en.md](docs/ink-bleed.en.md).

```ini
theme = ink-ultramarine
background-opacity = 0.8
background-opacity-cells = true
window-padding-x = 12
custom-shader = ~/.config/ghostty/shaders/bleed-measure.glsl
custom-shader = ~/.config/ghostty/shaders/bleed-spread.glsl
custom-shader = ~/.config/ghostty/shaders/bleed.glsl
custom-shader-animation = false
```

<table>
<tr><td width="50%" valign="top"><a href="docs/previews/ink-ultramarine.jpg"><img src="docs/previews/ink-ultramarine.jpg" alt="ink-ultramarine"></a><br><code>ink-ultramarine</code><br>Violet-leaning ultramarine ink under pearl text; cornflower, champagne, leaf green, rose, lavender and emerald.</td><td width="50%"></td></tr>
</table>

<a id="diamond"></a>

## Diamond glass

The whole window becomes a piece of colored gem glass. Its hue drifts like opal between neighboring colors at constant lightness, so text contrast is the same everywhere; light splits softly at the upper right and a few fixed glints sit on the edge. The first four are bright, the last four their dark twins.

```ini
theme = diamond-opal
background-opacity = 0.8
background-opacity-cells = true
custom-shader = ~/.config/ghostty/shaders/diamond.glsl
custom-shader-animation = false
```

Swap `theme` for any name below; the shader stays the same.

<table>
<tr><td width="50%" valign="top"><a href="docs/previews/diamond-opal.jpg"><img src="docs/previews/diamond-opal.jpg" alt="diamond-opal"></a><br><code>diamond-opal</code><br>Iridescent violet, drifting toward sapphire and rose.</td><td width="50%" valign="top"><a href="docs/previews/diamond-ruby.jpg"><img src="docs/previews/diamond-ruby.jpg" alt="diamond-ruby"></a><br><code>diamond-ruby</code><br>Ruby rose, drifting toward violet and crimson.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/diamond-sapphire.jpg"><img src="docs/previews/diamond-sapphire.jpg" alt="diamond-sapphire"></a><br><code>diamond-sapphire</code><br>Royal blue, drifting toward cerulean and indigo.</td><td width="50%" valign="top"><a href="docs/previews/diamond-aqua.jpg"><img src="docs/previews/diamond-aqua.jpg" alt="diamond-aqua"></a><br><code>diamond-aqua</code><br>Sea-glass teal, drifting toward mint and sapphire.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/diamond-amethyst.jpg"><img src="docs/previews/diamond-amethyst.jpg" alt="diamond-amethyst"></a><br><code>diamond-amethyst</code><br>Deep royal purple, drifting toward indigo and plum.</td><td width="50%" valign="top"><a href="docs/previews/diamond-garnet.jpg"><img src="docs/previews/diamond-garnet.jpg" alt="diamond-garnet"></a><br><code>diamond-garnet</code><br>Deep wine garnet, the dark twin of Ruby.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/diamond-abyss.jpg"><img src="docs/previews/diamond-abyss.jpg" alt="diamond-abyss"></a><br><code>diamond-abyss</code><br>Deep-ocean navy, drifting toward sea teal and indigo.</td><td width="50%" valign="top"><a href="docs/previews/diamond-tourmaline.jpg"><img src="docs/previews/diamond-tourmaline.jpg" alt="diamond-tourmaline"></a><br><code>diamond-tourmaline</code><br>Deep teal tourmaline, the dark twin of Aqua.</td></tr>
</table>

<a id="crayon"></a>

## Crayon watercolor

The terminal background becomes a sheet of watercolor paper. A few washes come in from the edges in the theme's own pigments (cursor, selection and bright yellow), gathering at the rim as they dry and settling into the paper tooth; two crayon strokes run around opposite corners inside the padding. The middle stays clear for text. The first four are light paper, the last four colored paper with the pigment lying on top like soft pastel.

```ini
theme = crayon-peach
background-opacity = 0.85
background-opacity-cells = true
custom-shader = ~/.config/ghostty/shaders/watercolor.glsl
custom-shader-animation = false
```

Swap `theme` for any name below; the shader stays the same.

<table>
<tr><td width="50%" valign="top"><a href="docs/previews/crayon-peach.jpg"><img src="docs/previews/crayon-peach.jpg" alt="crayon-peach"></a><br><code>crayon-peach</code><br>Cream paper, peach and rose washes, a coral crayon.</td><td width="50%" valign="top"><a href="docs/previews/crayon-lemon.jpg"><img src="docs/previews/crayon-lemon.jpg" alt="crayon-lemon"></a><br><code>crayon-lemon</code><br>Butter paper, lemon and mint washes, a marigold crayon.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/crayon-lilac.jpg"><img src="docs/previews/crayon-lilac.jpg" alt="crayon-lilac"></a><br><code>crayon-lilac</code><br>Lavender paper with lilac and periwinkle washes.</td><td width="50%" valign="top"><a href="docs/previews/crayon-seaside.jpg"><img src="docs/previews/crayon-seaside.jpg" alt="crayon-seaside"></a><br><code>crayon-seaside</code><br>Pale sea-salt paper with sky and aqua washes.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/crayon-starry.jpg"><img src="docs/previews/crayon-starry.jpg" alt="crayon-starry"></a><br><code>crayon-starry</code><br>Indigo night paper, a lemon-star crayon, blue washes.</td><td width="50%" valign="top"><a href="docs/previews/crayon-cocoa.jpg"><img src="docs/previews/crayon-cocoa.jpg" alt="crayon-cocoa"></a><br><code>crayon-cocoa</code><br>Warm kraft paper with apricot and rose pastel.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/crayon-moss.jpg"><img src="docs/previews/crayon-moss.jpg" alt="crayon-moss"></a><br><code>crayon-moss</code><br>Deep moss paper with lime and sage pastel.</td><td width="50%" valign="top"><a href="docs/previews/crayon-berry.jpg"><img src="docs/previews/crayon-berry.jpg" alt="crayon-berry"></a><br><code>crayon-berry</code><br>Plum paper with pink and lilac pastel.</td></tr>
</table>

<a id="paintings"></a>

## Paintings

Four full paintings behind the terminal. They are detailed, and a low opacity lets the wallpaper muddy them, so 0.95 or higher is recommended.

```ini
theme = paint-dusk
background-opacity = 0.97
background-opacity-cells = true
```

<table>
<tr><td width="50%" valign="top"><a href="docs/previews/paint-dusk.jpg"><img src="docs/previews/paint-dusk.jpg" alt="paint-dusk"></a><br><code>paint-dusk</code><br>Blue-hour sky in the manner of anime backgrounds, clouds lit from below by the last of the sunset, a dark ridge along the bottom.</td><td width="50%" valign="top"><a href="docs/previews/crayon-night.jpg"><img src="docs/previews/crayon-night.jpg" alt="crayon-night"></a><br><code>crayon-night</code><br>A crayon drawing on navy construction paper: moon, stars, sky swirls, hatched hills, lollipop trees and a house with a lit window.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/ink-moon.jpg"><img src="docs/previews/ink-moon.jpg" alt="ink-moon"></a><br><code>ink-moon</code><br>An ink-wash landscape inverted for the dark: peaks fading into mist, a moon, birds, a small boat and a red seal.</td><td width="50%" valign="top"><a href="docs/previews/impression-dawn.jpg"><img src="docs/previews/impression-dawn.jpg" alt="impression-dawn"></a><br><code>impression-dawn</code><br>A harbor at dawn in broken brushwork after Monet: blue-gray haze, an orange sun and its reflection, dark boats.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/scroll-qingming.jpg"><img src="docs/previews/scroll-qingming.jpg" alt="scroll-qingming"></a><br><code>scroll-qingming</code><br>The rainbow-bridge section of Along the River During the Qingming Festival, redrawn on dark aged silk: a crowded bridge, a boat lowering its mast, shops and willows.</td><td width="50%"></td></tr>
</table>

<a id="toon"></a>

## Cel-shaded

Shaded like anime cels: flat shadow and light planes and a hard rim of light on every form.

```ini
theme = toon-planet
background-opacity = 0.8
background-opacity-cells = true
```

<table>
<tr><td width="50%" valign="top"><a href="docs/previews/toon-planet.jpg"><img src="docs/previews/toon-planet.jpg" alt="toon-planet"></a><br><code>toon-planet</code><br>A ringed planet and a moon: hard light bands, a cyan rim light, manga halftone in the shadows, heavy outlines.</td><td width="50%" valign="top"><a href="docs/previews/toon-koi.jpg"><img src="docs/previews/toon-koi.jpg" alt="toon-koi"></a><br><code>toon-koi</code><br>A dark pond seen from above: koi, lily pads and lotus, their shadows on the pond floor, ripples and petals.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/toon-castle.jpg"><img src="docs/previews/toon-castle.jpg" alt="toon-castle"></a><br><code>toon-castle</code><br>A castle on a rocky island at dusk: round towers with conical roofs, a steep hall, warm windows, a mirroring lake.</td><td width="50%" valign="top"><a href="docs/previews/toon-citadel.jpg"><img src="docs/previews/toon-citadel.jpg" alt="toon-citadel"></a><br><code>toon-citadel</code><br>A gothic royal citadel on sheer walls, the low sun hidden behind its keep: flat cel planes, hard gold rims, god rays, cel-lit clouds, mist in the chasm.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/toon-leyndell.jpg"><img src="docs/previews/toon-leyndell.jpg" alt="toon-leyndell"></a><br><code>toon-leyndell</code><br>A royal capital of golden domes and high walls at dusk under a colossal golden tree: a braided trunk and a glowing crown shedding leaves.</td><td width="50%"></td></tr>
</table>

<a id="glitch"></a>

## Glitch

Frozen digital glitches, kept to the right and bottom so the left stays calm for text.

```ini
theme = glitch-signal
background-opacity = 0.8
background-opacity-cells = true
```

<table>
<tr><td width="50%" valign="top"><a href="docs/previews/glitch-signal.jpg"><img src="docs/previews/glitch-signal.jpg" alt="glitch-signal"></a><br><code>glitch-signal</code><br>Torn type, split color channels, pixel-sort streaks, compression blocks and scanlines.</td><td width="50%" valign="top"><a href="docs/previews/glitch-peony.jpg"><img src="docs/previews/glitch-peony.jpg" alt="glitch-peony"></a><br><code>glitch-peony</code><br>A full peony corrupted: pixel-sorted drips, slices knocked sideways, channels out of register.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/glitch-mirage.jpg"><img src="docs/previews/glitch-mirage.jpg" alt="glitch-mirage"></a><br><code>glitch-mirage</code><br>Low-poly mountains over a still lake in vaporwave colors: rows sorted into light, mosaic blocks, a little chromatic aberration.</td><td width="50%" valign="top"><a href="docs/previews/glitch-eclipse.jpg"><img src="docs/previews/glitch-eclipse.jpg" alt="glitch-eclipse"></a><br><code>glitch-eclipse</code><br>A crisp black sun with a white-hot corona, cut into clean slices with red/cyan channel splits, pixel-exact blocks and HUD type. Nothing blurred.</td></tr>
</table>

<a id="cyber"></a>

## Cyber

Neon, rain and the city at night.

```ini
theme = cyber-neon
background-opacity = 0.8
background-opacity-cells = true
```

<table>
<tr><td width="50%" valign="top"><a href="docs/previews/cyber-neon.jpg"><img src="docs/previews/cyber-neon.jpg" alt="cyber-neon"></a><br><code>cyber-neon</code><br>A night skyline with neon rims and vertical signs, a perspective grid floor, HUD brackets and a reticle.</td><td width="50%" valign="top"><a href="docs/previews/cyber-sakura.jpg"><img src="docs/previews/cyber-sakura.jpg" alt="cyber-sakura"></a><br><code>cyber-sakura</code><br>A rainy night: a torii outlined in neon, glowing cherry branches, drifting petals, a wet floor mirroring the light.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/cyber-skyrail.jpg"><img src="docs/previews/cyber-skyrail.jpg" alt="cyber-skyrail"></a><br><code>cyber-skyrail</code><br>Inside a sky-rail car at night: wide windows onto a rainy neon city and a low moon, another train sliding past, a route display and hand straps.</td><td width="50%" valign="top"><a href="docs/previews/cyber-skycity.jpg"><img src="docs/previews/cyber-skycity.jpg" alt="cyber-skycity"></a><br><code>cyber-skycity</code><br>A machine city hanging in the night sky: towers on top, decks of pipes and gears, an engine firing beams into the clouds, traffic streaking around it.</td></tr>
</table>

<a id="retro"></a>

## Retro

Old print: a few flat inks, halftone, paper grain and a little misregistration.

```ini
theme = retro-seventies
background-opacity = 0.8
background-opacity-cells = true
```

<table>
<tr><td width="50%" valign="top"><a href="docs/previews/retro-seventies.jpg"><img src="docs/previews/retro-seventies.jpg" alt="retro-seventies"></a><br><code>retro-seventies</code><br>A 1970s poster: arched stripes, a sliced sun, sparkles and halftone on dark brown stock.</td><td width="50%" valign="top"><a href="docs/previews/retro-flowerpower.jpg"><img src="docs/previews/retro-flowerpower.jpg" alt="retro-flowerpower"></a><br><code>retro-flowerpower</code><br>A 1970s print: big round-petaled daisies and groovy wavy stripes.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/retro-steampunk.jpg"><img src="docs/previews/retro-steampunk.jpg" alt="retro-steampunk"></a><br><code>retro-steampunk</code><br>Brass and copper machinery on dark sepia: gears, a pressure gauge, copper pipes and a valve wheel, a wisp of steam, faint engineering drawings.</td><td width="50%" valign="top"><a href="docs/previews/retro-gramophone.jpg"><img src="docs/previews/retro-gramophone.jpg" alt="retro-gramophone"></a><br><code>retro-gramophone</code><br>A 1930s Hollywood magazine cover in Art Deco: sunburst, premiere searchlights over a picture palace, a brass gramophone, gold masthead, stepped frame.</td></tr>
</table>

<a id="cartoon"></a>

## Cartoon

The light-hearted ones.

```ini
theme = sticker-pop
background-opacity = 0.8
background-opacity-cells = true
```

<table>
<tr><td width="50%" valign="top"><a href="docs/previews/sticker-pop.jpg"><img src="docs/previews/sticker-pop.jpg" alt="sticker-pop"></a><br><code>sticker-pop</code><br>Cartoon stickers with die-cut borders around the corners and right edge of a dark polka-dot background.</td><td width="50%" valign="top"><a href="docs/previews/sticker-garden.jpg"><img src="docs/previews/sticker-garden.jpg" alt="sticker-garden"></a><br><code>sticker-garden</code><br>The same polka dots with garden stickers.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/cartoon-teahouse.jpg"><img src="docs/previews/cartoon-teahouse.jpg" alt="cartoon-teahouse"></a><br><code>cartoon-teahouse</code><br>A milk-tea shop at night: pendant lamps, a chalkboard menu, a shelf of jars and plants, boba, a latte, an espresso machine and a sleeping cat.</td><td width="50%" valign="top"><a href="docs/previews/cartoon-laputa.jpg"><img src="docs/previews/cartoon-laputa.jpg" alt="cartoon-laputa"></a><br><code>cartoon-laputa</code><br>Blue hour, painted like a Ghibli background: a cumulonimbus holding the last light, a floating island with its great tree, waterfalls and roots, a sea of cloud.</td></tr>
</table>

<a id="glass"></a>

## Glass

Each image is a PNG with an alpha channel: part of it is painted solid and the rest is left as glass, so your wallpaper shows through and becomes part of the picture. The theme files set `background-image-opacity = 1.9`, which brings the solid parts back to full opacity; `background-opacity` has to be set to 0.5 in your own config, because the config overrides a theme.

```ini
theme = glass-moongate
background-opacity = 0.5
background-opacity-cells = true
```

<table>
<tr><td width="50%" valign="top"><a href="docs/previews/glass-moongate.jpg"><img src="docs/previews/glass-moongate.jpg" alt="glass-moongate"></a><br><code>glass-moongate</code><br>A garden wall at night with a round moon gate and a plum branch. The wall is solid; through the gate you see your desktop.</td><td width="50%" valign="top"><a href="docs/previews/glass-aurora.jpg"><img src="docs/previews/glass-aurora.jpg" alt="glass-aurora"></a><br><code>glass-aurora</code><br>A curtain of aurora across the glass, a few stars, and a solid spruce ridge along the bottom where the last lines of output sit.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/glass-rain.jpg"><img src="docs/previews/glass-rain.jpg" alt="glass-rain"></a><br><code>glass-rain</code><br>A window on a rainy night: condensation on the glass, with drops and running trails wiping it clear so the desktop shows through.</td><td width="50%"></td></tr>
</table>

<a id="lace"></a>

## Lace

Dark lace laid over the glass. The threads are dark, so text stays readable on them; the net lets a little of the desktop through, and each design leaves one opening at the upper right where the desktop shows most. The openings are placed for a full-screen window and suit a wallpaper with a figure or subject in that area. Set `background-opacity` to 0.5, as for the glass themes.

```ini
theme = lace-cameo
background-opacity = 0.5
background-opacity-cells = true
```

<table>
<tr><td width="50%" valign="top"><a href="docs/previews/lace-cameo.jpg"><img src="docs/previews/lace-cameo.jpg" alt="lace-cameo"></a><br><code>lace-cameo</code><br>Cameo: midnight-navy tulle over the whole pane, an oval cameo window at the upper right framed in Chantilly lace, borders along the top and bottom.</td><td width="50%" valign="top"><a href="docs/previews/lace-curtain.jpg"><img src="docs/previews/lace-curtain.jpg" alt="lace-curtain"></a><br><code>lace-curtain</code><br>Curtains: black lace curtains tied back over a café curtain, leaving one window open at the upper right.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/lace-veil.jpg"><img src="docs/previews/lace-veil.jpg" alt="lace-veil"></a><br><code>lace-veil</code><br>Veil: a deep violet point d'esprit veil falling from the upper left and swept aside at the upper right, edged with broad lace.</td><td width="50%"></td></tr>
</table>

<a id="muse"></a>

## Muse

Another take on the transparent themes: the opening is not an oval or a window but the outline of a figure in one particular wallpaper (traced from it with macOS subject lifting; none of the wallpaper itself is in the images), so the figure seems to stand in front of the picture, the hair crossing the frame and covering the masthead. The four borrow from Mucha, Klimt, a fashion magazine cover and Mondrian. The outline is placed for that wallpaper in a full-screen window; with any other wallpaper the cut-out shows whatever sits there, the way the sky does in the previews. Everything that can sit behind text is kept dark enough for white text. Set `background-opacity` to 0.5, as for the glass themes.

```ini
theme = muse-mucha
background-opacity = 0.5
background-opacity-cells = true
```

<table>
<tr><td width="50%" valign="top"><a href="docs/previews/muse-mucha.jpg"><img src="docs/previews/muse-mucha.jpg" alt="muse-mucha"></a><br><code>muse-mucha</code><br>Mucha: after "Byzantine Head: The Blonde", the figure before a jewelled medallion with the hair crossing the ring, gold whiplash tendrils, poppies and a frieze of fans.</td><td width="50%" valign="top"><a href="docs/previews/muse-klimt.jpg"><img src="docs/previews/muse-klimt.jpg" alt="muse-klimt"></a><br><code>muse-klimt</code><br>Klimt: after "Portrait of Adele Bloch-Bauer I", only the face, hair and shoulders stay open; the rest becomes a dark-gold gown in wavy panels of eyes, spirals and rectangles, in a field of gold mosaic.</td></tr>
<tr><td width="50%" valign="top"><a href="docs/previews/muse-cover.jpg"><img src="docs/previews/muse-cover.jpg" alt="muse-cover"></a><br><code>muse-cover</code><br>Cover: the right half is the cover photograph, the figure standing in front of a deep red Didot masthead, with cover lines, a French sticker and a barcode; the black page on the left is for text.</td><td width="50%" valign="top"><a href="docs/previews/muse-mondrian.jpg"><img src="docs/previews/muse-mondrian.jpg" alt="muse-mondrian"></a><br><code>muse-mondrian</code><br>Mondrian: "Broadway Boogie Woogie" after dark, mustard lines broken by oxblood, navy and slate squares, the figure in one open cell with the head breaking through the grid.</td></tr>
</table>

## Notes

Every preview is a real Ghostty window captured at the recommended opacity for its collection, placed over a procedurally generated sky. In use, your own wallpaper shows through instead; for the transparent themes, what appears in the glass and the openings depends entirely on your wallpaper.

Background themes use Ghostty's `background-image`, which needs version 1.2 or newer. The image covers the window and stays centered, so a window with a different aspect ratio crops a little off the sides. Most of each picture sits on the right and at the bottom, leaving the top left for text.

Once any custom shader is loaded, Ghostty 1.3.1 redraws a focused window at the display refresh rate, so shader themes cost more GPU than background themes. See the [ink bleed performance numbers](docs/ink-bleed.en.md#performance).

Only tested with Ghostty 1.3.1 on macOS. The shaders assume two pixels per point (Retina); on a 1× display their textures look twice as coarse, and everything still works.

## Layout

```
themes/        theme files, 53 of them
shaders/       bleed-measure / bleed-spread / bleed (ink bleed), diamond (diamond glass), watercolor (crayon watercolor)
backgrounds/   images for the background and transparent themes, 3024×1964; the transparent ones are PNGs with alpha
docs/          previews, cover and the ink bleed write-up
install.sh     installer
```

## License

MIT, covering the code, the themes and the background images.
