#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

REPOS="${SCRIPT_DIR}/external_repos/wayland \
${SCRIPT_DIR}/external_repos/wayland-protocols \
${SCRIPT_DIR}/external_repos/xkbcommon \
${SCRIPT_DIR}/external_repos/wlroots"


rm -r ${SCRIPT_DIR}/artifacts

for repo in ${REPOS}; do
    rm -r ${repo}/generated ${repo}/build
done