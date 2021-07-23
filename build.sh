#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

REPOS="${SCRIPT_DIR}/external_repos/wayland \
${SCRIPT_DIR}/external_repos/wayland-protocols \
${SCRIPT_DIR}/external_repos/xkbcommon \
${SCRIPT_DIR}/external_repos/wlroots"

for repo in ${REPOS}; do
    echo ""
    echo "Building ${repo} for ${ANDROID_ARCH}..."
    echo ""
    pushd "${repo}"
    ./build.sh $@
    popd
done