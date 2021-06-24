#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ARCHS=$(ls ${SCRIPT_DIR}/prebuilt)

for arch in ${ARCHS}; do
    ANDROID_ARCH=${arch} ANDROID_TARGET=${arch}-linux-android ${SCRIPT_DIR}/build.sh
done