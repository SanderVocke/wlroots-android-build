#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ARCH_LONG=${ANDROID_TARGET}${ANDROID_API}
ARTIFACTS=${SCRIPT_DIR}/../../artifacts/${ANDROID_ARCH}
PREBUILT=${SCRIPT_DIR}/../../prebuilt/${ANDROID_ARCH}

# We have to patch the pkgconfig files to prepend our path
# to their prefix.
# Unfortunately there is no way to set --define-prefix as a pkgconfig argument
# via Meson, which would be a lot easier.
BASE_PKGCONFIG_DIR=../../prebuilt/${ANDROID_ARCH}/lib/pkgconfig
PKGCONFIG_DIR=${SCRIPT_DIR}/generated/${ANDROID_ARCH}/pkgconfig-dir
mkdir -p ${PKGCONFIG_DIR}
ESCAPED_PREBUILT="${PREBUILT//\//\\/}"
for f in ${BASE_PKGCONFIG_DIR}/*.pc; do
    sed "s/^prefix=.*/prefix=${ESCAPED_PREBUILT}/g" ${BASE_PKGCONFIG_DIR}/$(basename ${f}) > ${PKGCONFIG_DIR}/$(basename ${f})
done

# Also include the .pc files from any packages we already built into
# the artifacts folder.
cp ${ARTIFACTS}/lib/pkgconfig/*.pc ${PKGCONFIG_DIR}
cp ${ARTIFACTS}/share/pkgconfig/*.pc ${PKGCONFIG_DIR}

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

pushd libxkbcommon
mkdir -p build
meson --cross-file=${SCRIPT_DIR}/generated/${ANDROID_ARCH}/meson.crossfile \
    -Dprefix=${ARTIFACTS} \
    -Denable-x11=false \
    ../build/${ANDROID_ARCH}
popd

ninja -C build/${ANDROID_ARCH}
ninja -C build/${ANDROID_ARCH} install