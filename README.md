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

## Using `patch-apk.sh` locally

You can also run the script directly without Docker if the required
Android tooling is installed.  The following utilities need to be
available in your `PATH`:

* `apktool`
* `zipalign`
* `apksigner`
* `xmlstarlet` (optional, improves manifest editing)

On most systems these can be installed via the Android SDK packages or
your distribution's package manager.  With the tools installed, invoke
the script just like the container image:

```bash
./patch-apk.sh myapp.apk 34 21
```

When run outside Docker the script will create a debug keystore under
`~/.android/` if one does not already exist.  The patched APK will be
written as `myapp-patched.apk` in the current directory.
