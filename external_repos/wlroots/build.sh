#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ "$ANDROID_ARCH" = "armv7a" ]; then
    ARCH_LONG=${ANDROID_TARGET}eabi${ANDROID_API}
else
    ARCH_LONG=${ANDROID_TARGET}${ANDROID_API}
fi
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

# Also manually create pkgconfigs for Android sysroot dependencies
cat > generated/${ANDROID_ARCH}/pkgconfig-dir/egl.pc <<- EOF
prefix=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib/${ANDROID_TARGET}/${ANDROID_API}/
includedir=\${prefix}/include

Name: EGL
Description: Generated dependency to point to Android EGL
Version: 1.0
Libs: -L\${libdir} -lEGL
Cflags: -I\${includedir}
EOF
cat > generated/${ANDROID_ARCH}/pkgconfig-dir/glesv2.pc <<- EOF
prefix=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib/${ANDROID_TARGET}/${ANDROID_API}/
includedir=\${prefix}/include

Name: GLESv2
Description: Generated dependency to point to Android EGL
Version: 1.0
Libs: -L\${libdir} -lGLESv2
Cflags: -I\${includedir}
EOF

# Create a faux .pc for libdrm, which will only be used to find
# some header files.
cat > generated/${ANDROID_ARCH}/pkgconfig-dir/libdrm.pc <<- EOF
prefix=${SCRIPT_DIR}/../libdrm/mesa-drm
includedir=\${prefix}/include/drm
includedir2=\${prefix}
exec_prefix=\${prefix}
libdir=\${prefix}

Name: libdrm
Description: Generated dependency to point to libdrm headers
Version: 2.4.106
Libs:
Cflags: -I\${includedir} -I\${includedir2}
EOF

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

# Copy the repo and apply a patch
# if [ ! -d generated/${ANDROID_ARCH}/wlroots ]; then
#     cp -r wlroots generated/${ANDROID_ARCH}/wlroots
#     pushd generated/${ANDROID_ARCH}/wlroots
#     #patch -p1 < ${SCRIPT_DIR}/android.patch
#     popd
# fi

mkdir -p ${SCRIPT_DIR}/build/${ANDROID_ARCH}

pushd wlroots
meson --cross-file=${SCRIPT_DIR}/generated/${ANDROID_ARCH}/meson.crossfile \
    -Dprefix=${ARTIFACTS} \
    ${SCRIPT_DIR}/build/${ANDROID_ARCH} \
    $@
popd

ninja -C build/${ANDROID_ARCH}
ninja -C build/${ANDROID_ARCH} install
