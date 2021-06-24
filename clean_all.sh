#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

rm -r ${SCRIPT_DIR}/prebuilt
./clean_builds.sh