#!/bin/bash
set -euo pipefail

ALBUM_DIR="./album"

if [ ! -d "$ALBUM_DIR" ]; then
  echo "错误：找不到目录 $ALBUM_DIR"
  exit 1
fi

converted=0
skipped=0
failed=0

while IFS= read -r -d '' file; do
  out="${file%.*}.mp3"

  if [ -f "$out" ]; then
    echo "跳过（已存在）：$out"
    skipped=$((skipped + 1))
    continue
  fi

  echo "转换：$file -> $out"
  if ffmpeg -nostdin -hide_banner -loglevel error -i "$file" \
      -c:a libmp3lame -b:a 320k "$out"; then
    converted=$((converted + 1))
  else
    echo "失败：$file" >&2
    failed=$((failed + 1))
  fi
done < <(find "$ALBUM_DIR" -type f \( -iname '*.wav' -o -iname '*.flac' \) -print0)

echo "完成：成功转换 $converted 个，跳过 $skipped 个，失败 $failed 个。"