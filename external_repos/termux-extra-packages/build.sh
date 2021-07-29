#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ "$ANDROID_ARCH" = "armv7a" ]; then
    ARCH_LONG=${ANDROID_TARGET}eabi${ANDROID_API}
else
    ARCH_LONG=${ANDROID_TARGET}${ANDROID_API}
fi
ARTIFACTS=${SCRIPT_DIR}/../../artifacts/${ANDROID_ARCH}
PREBUILT=${SCRIPT_DIR}/../../prebuilt/${ANDROID_ARCH}

# Replace paths with the ones to your NDK tools
mkdir -p generated/${ANDROID_ARCH}
cat > generated/${ANDROID_ARCH}/meson.crossfile <<- EOF
[binaries]
c = '$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/${ARCH_LONG}-clang'
cpp = '$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/${ARCH_LONG}-clang++'
ar = '$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-ar'
ld = '$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/ld'
strip = '$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip'
# Android doesn't come with a pkg-config, but we need one for meson to be happy not
# finding all the optional deps it looks for.  Use system pkg-config pointing at a
# directory we get to populate with any .pc files we want to add for Android
pkgconfig = ['env', 'PKG_CONFIG_LIBDIR=$PKGCONFIG_DIR', '/usr/bin/pkg-config']

[properties]
root = '$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot'
needs_exe_wrapper = false

[host_machine]
system = 'android-arm'
cpu_family = 'arm'
cpu = '${ANDROID_ARCH}'
endian = 'little'
EOF

POSIX_SHM_PACKAGE_VERSION=$(source $SCRIPT_DIR/termux-extra-packages/packages/libposix-shm/build.sh && echo $TERMUX_PKG_VERSION)

mkdir -p build
meson --cross-file=${SCRIPT_DIR}/generated/${ANDROID_ARCH}/meson.crossfile \
    -Dprefix=${ARTIFACTS} \
    -Dposix_shm_version=${POSIX_SHM_PACKAGE_VERSION} \
    ${SCRIPT_DIR}/build/${ANDROID_ARCH} \
    $@

ninja -C build/${ANDROID_ARCH}
ninja -C build/${ANDROID_ARCH} install
