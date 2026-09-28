#!/bin/sh
# Copy the themes, shaders and background images into ~/.config/ghostty.
# Your own config file is never touched; pick a theme there afterwards.
# The theme files point at ~/.config/ghostty/backgrounds, so that is where the
# images go even if Ghostty also reads a config from somewhere else.
set -e
cd "$(dirname "$0")"
dest="$HOME/.config/ghostty"
mkdir -p "$dest/themes" "$dest/shaders" "$dest/backgrounds"
cp themes/* "$dest/themes/"
cp shaders/*.glsl "$dest/shaders/"
cp backgrounds/*.jpg "$dest/backgrounds/"
echo "Installed $(ls themes | wc -l | tr -d ' ') themes, $(ls shaders | wc -l | tr -d ' ') shaders and $(ls backgrounds | wc -l | tr -d ' ') backgrounds into $dest"
