#!/usr/bin/env bash
# Create sample data for testing patch-apk.sh
set -euo pipefail

OUT_DIR="testdata"
URL="https://github.com/appium/sample-code/raw/master/sample-code/apps/ApiDemos-debug.apk"

mkdir -p "$OUT_DIR"

DEST="$OUT_DIR/ApiDemos-debug.apk"

if [ ! -f "$DEST" ]; then
  echo "Downloading sample APK..."
  curl -L "$URL" -o "$DEST"
else
  echo "Sample APK already exists: $DEST"
fi

echo "Test data available at $DEST"
