#!/usr/bin/env bash
# Create sample data for testing patch-apk.sh
set -euo pipefail

OUT_DIR="testdata"
# Small open-source app from F-Droid
URL="https://f-droid.org/repo/com.simplemobiletools.notes_26.apk"

mkdir -p "$OUT_DIR"

DEST="$OUT_DIR/sample.apk"

if [ ! -f "$DEST" ]; then
  echo "Downloading sample APK to $DEST..." >&2
  curl -fsSL "$URL" -o "$DEST"
else
  echo "Sample APK already exists: $DEST" >&2
fi

# Print the path so callers can capture it
echo "$DEST"
