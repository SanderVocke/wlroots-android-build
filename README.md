This repository has a cross-compiling environment for building wlroots and its dependencies for Android with an Android NDK.

There is no original code here except the build scripts. Other than that it is a collection of work by others:
- Submodules for wlroots and several of its dependencies
- Other dependencies extracted from Termux packages
- [this patch](https://gist.github.com/twaik/50b82028a0bd3192bec4d98b9ae522a6) by [twaik](https://gist.github.com/twaik), which allows wlroots to build against the NDK.

Usage:
- Modify default_env.sourceme to point to your NDK and desired toolchain
- Source it
- Run the build.sh scripts in each external repository. Note that wlroots depends on wayland, wayland-protocols and xkbcommon, so build those first.
- Results are installed in the artifacts folder.

Notes:
- Only set up for aarch64 at the moment. If you want another architecture, that would mean:
    - Change ANDROID_ARCH in the default_env.sourceme
    - Download the prebuilt dependencies for that architecture and extract into prebuilt/ as it was done for aarch64.
    - wlroots 0.6.0 is a bit old. My brief attempts to patch the latest release failed - it seems that the dependency on GBM and DRM makes this difficult.