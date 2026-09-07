#!/usr/bin/env bash
# Regenerate assets/demo.gif from assets/demo.mp4
#
# Needs ffmpeg:  brew install ffmpeg
# Optional, smaller output:  brew install gifski
#
# After running, update README.md: swap the demo-poster.jpg image line for demo.gif
# (the commented line right below it).
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1
SRC="assets/demo.mp4"
OUT="assets/demo.gif"
FPS="${FPS:-12}"
WIDTH="${WIDTH:-960}"

if ! command -v ffmpeg >/dev/null; then
  echo "ffmpeg not found — run: brew install ffmpeg" >&2
  exit 1
fi

if command -v gifski >/dev/null; then
  TMP="$(mktemp -d)"
  ffmpeg -y -i "$SRC" -vf "fps=$FPS,scale=$WIDTH:-1:flags=lanczos" "$TMP/frame%04d.png"
  gifski --quality 80 --fps "$FPS" -o "$OUT" "$TMP"/frame*.png
  rm -rf "$TMP"
else
  # palette method keeps colors clean without gifski
  PAL="$(mktemp -d)/palette.png"
  ffmpeg -y -i "$SRC" -vf "fps=$FPS,scale=$WIDTH:-1:flags=lanczos,palettegen=stats_mode=diff" "$PAL"
  ffmpeg -y -i "$SRC" -i "$PAL" -lavfi "fps=$FPS,scale=$WIDTH:-1:flags=lanczos [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" "$OUT"
  rm -rf "$(dirname "$PAL")"
fi

echo "wrote $OUT ($(du -h "$OUT" | cut -f1))"
echo "keep it under ~5 MB for directory renderers; lower FPS/WIDTH if needed."
