#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ARCH_LONG=${ANDROID_TARGET}${ANDROID_API}
ARTIFACTS=${SCRIPT_DIR}/../../artifacts/${ANDROID_ARCH}
PKGCONFIG_DIR=${ARTIFACTS}/lib/pkgconfig

# Make our own pkgconfig directory to point dependencies
# to the right places
# PKGCONFIG_DIR=${SCRIPT_DIR}/generated/pkgconfig-dir
# rm -r ${PKGCONFIG_DIR}
# mkdir -p ${PKGCONFIG_DIR}
# cat > generated/pkgconfig-dir/wayland-server.pc <<- EOF
# prefix=${SCRIPT_DIR}/termux-x11/app/src/main/jni/prebuilt/
# exec_prefix=\${prefix}
# includedir=\${prefix}/include
# libdir=\${exec_prefix}/${ANDROID_ARCH}

# Name: wayland-server
# Description: Wayland protocol server library
# Version: 1.19
# Cflags: -I\${includedir}/
# Libs: -L\${libdir} -lwayland-server
# EOF

# Replace paths with the ones to your NDK tools
cat > generated/meson.crossfile <<- EOF
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

pushd wayland
mkdir -p build
meson --cross-file=${SCRIPT_DIR}/generated/meson.crossfile build/
ninja -C build/
popd