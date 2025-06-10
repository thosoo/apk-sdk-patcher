# APK SDK Patcher

This repository provides `patch-apk.sh`, a helper script to adjust the
`targetSdk` (and optionally the `minSdk`) of an existing APK.  A lightweight
Docker image is available for running the script without installing any
Android tools on the host system.

## Building the image

```bash
docker build -t apk-patcher .
```

## Using the container

Place the APK you want to patch in the current directory and run:

```bash
docker run --rm -v "$PWD:/work" apk-patcher your.apk [targetSdk] [minSdk]
```

To view usage information run:

```bash
docker run --rm apk-patcher --help
```

The patched APK is written to the same directory as `your-patched.apk`.
