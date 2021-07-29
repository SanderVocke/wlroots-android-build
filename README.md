This repository has a cross-compiling environment for building wlroots and its dependencies for Android with an Android NDK.

Important: For now I am using this to build a fork of wlroots which has some modifications. It is hosted on a private server for now, so you may
not be able to checkout the wlroots submodule. You can still get a version that builds:
- For the wlroots submodule: check out version 0.6.0 from the official wlroots repo.
- Apply the patch by twaik from his Gist: https://gist.github.com/twaik/50b82028a0bd3192bec4d98b9ae522a6



There is no original code here except the build scripts. Other than that it is a collection of work by others:
- Submodules for wlroots and several of its dependencies
- Other dependencies extracted from Termux packages
- [this patch](https://gist.github.com/twaik/50b82028a0bd3192bec4d98b9ae522a6) by [twaik](https://gist.github.com/twaik), which allows wlroots to build against the NDK.

Usage:
- Ensure that some env variables are set to choose the desired NDK and target options.
  See default_env.sourceme for an example (you can also just modify and source that one).
- Run the download_packages.sh script in the top-level directory. It should download and extract
  a bunch of Termux packages into prebuilt/.
- Build in one of the following ways:
  - Run build_all.sh in the top-level directory to build for all the architectures for which
    Termux packages were found. ANDROID_ARCH does not need to be set in this case.
  - Run build.sh in the top-level directory to build for a specific ANDROID_ARCH.
  - Run the build.sh scripts in each external repository. Note that wlroots depends on wayland, wayland-protocols and xkbcommon, so build those first.
- Note that any arguments passed to the build script will be forwarded to Meson, e.g. to choose
  the build type.
- Results are installed in the artifacts folder.

Notes:
- wlroots 0.6.0 is a bit old. My brief attempts to patch the latest release failed - it seems that the dependency on GBM and DRM makes this difficult.
