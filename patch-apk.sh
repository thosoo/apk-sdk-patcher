#!/usr/bin/env bash
# Patch any APK to raise its targetSdk (default 34) and minSdk (optional).
# Usage: ./patch-apk.sh app.apk [targetSdk] [minSdk]
set -euo pipefail

APK_IN="$1"
TARGET_SDK="${2:-34}"          # default → Android 14
MIN_SDK="${3:-}"               # leave blank to keep original
WORKDIR="$(mktemp -d)"
NAME="$(basename "${APK_IN%.*}")"
OUT_DIR="$WORKDIR/out"
PATCHED_APK="${NAME}-patched.apk"
KEYSTORE="$HOME/.android/debug.keystore"
ALIAS=androiddebugkey
STOREPASS=android
KEYPASS=android

cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

echo "➤ Decompiling..."
apktool d -q "$APK_IN" -o "$OUT_DIR"

echo "➤ Patching AndroidManifest.xml..."
MANIFEST="$OUT_DIR/AndroidManifest.xml"

if command -v xmlstarlet >/dev/null 2>&1; then
  # Update or create uses-sdk element
  if xmlstarlet sel -t -c "/manifest/uses-sdk" "$MANIFEST" >/dev/null 2>&1; then
    xmlstarlet ed -L \
      -u "/manifest/uses-sdk/@android:targetSdkVersion" -v "$TARGET_SDK" \
      ${MIN_SDK:+ -u "/manifest/uses-sdk/@android:minSdkVersion" -v "$MIN_SDK"} \
      "$MANIFEST"
  else
    # Add missing uses-sdk just inside <manifest>
    xmlstarlet ed -L \
      -s /manifest -t elem -n uses-sdk -v "" \
      -i "/manifest/uses-sdk" -t attr -n "android:targetSdkVersion" -v "$TARGET_SDK" \
      ${MIN_SDK:+ -i "/manifest/uses-sdk" -t attr -n "android:minSdkVersion" -v "$MIN_SDK"} \
      "$MANIFEST"
  fi
else
  # Fallback: naïve sed (works for simple manifests)
  sed -i.bak -E \
    "s/android:targetSdkVersion=\"[0-9]+\"/android:targetSdkVersion=\"$TARGET_SDK\"/g" \
    "$MANIFEST"
  [ -n "$MIN_SDK" ] && \
    sed -i -E "s/android:minSdkVersion=\"[0-9]+\"/android:minSdkVersion=\"$MIN_SDK\"/g" \
    "$MANIFEST"
fi

echo "➤ Rebuilding..."
apktool b -q "$OUT_DIR" -o "$WORKDIR/$PATCHED_APK"

echo "➤ Zip-aligning..."
zipalign -f -p 4 "$WORKDIR/$PATCHED_APK" "$WORKDIR/aligned.apk"

# Create debug keystore if missing
if [ ! -f "$KEYSTORE" ]; then
  echo "➤ Generating debug keystore..."
  keytool -genkeypair -v -keystore "$KEYSTORE" -alias "$ALIAS" \
          -storepass "$STOREPASS" -keypass "$KEYPASS" \
          -dname "CN=Android Debug,O=Android,C=US" \
          -keyalg RSA -keysize 2048 -validity 10000 >/dev/null
fi

echo "➤ Signing..."
apksigner sign --ks "$KEYSTORE" --ks-pass "pass:$STOREPASS" \
               --key-pass "pass:$KEYPASS" --out "$PATCHED_APK" \
               "$WORKDIR/aligned.apk"

echo "✅ Done! Output: $PATCHED_APK"
echo "ℹ️  Install with:  adb install -r $PATCHED_APK"
