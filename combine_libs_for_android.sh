#!/bin/bash

# For use in Android packages, it is a pain to have versioned .so's because symlinks
# cannot be used in AAR libraries to point to .so's.
# This script takes all the libraries from the prebuilt and artifact folders,
# removes symlinks, renames all .so.x.x.x files to .so and replaces dependencies
# inside them of the form .so.x.x.x to .so as well.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

rm -rf ${SCRIPT_DIR}/android_libs_unversioned
mkdir -p android_libs_unversioned

# Initial copy
rsync -avzh --include="*.so*" ${SCRIPT_DIR}/prebuilt/* ${SCRIPT_DIR}/android_libs_unversioned/prebuilt
rsync -avzh --include="*.so*" ${SCRIPT_DIR}/artifacts/* ${SCRIPT_DIR}/android_libs_unversioned/artifacts

# Remove symlinks
find ${SCRIPT_DIR}/android_libs_unversioned -type l -delete

# Rename .so.* to .so
find ${SCRIPT_DIR}/android_libs_unversioned -name "*.so*" | while read line; do 
    file=$line
    renamed=$(echo $file | sed -r 's/\.so.*/\.so/')
    mv $file $renamed
done

# Replace any dependencies and SONAME's to .so.* to .so
find ${SCRIPT_DIR}/android_libs_unversioned -name "*.so" | while read line; do
    file=${line}
    patchelf --print-needed $file | while read dep; do
        renamed=$(echo $dep | sed -r 's/\.so.*/\.so/')
        if [[ "$dep" != "$renamed" ]]; then
            patchelf --replace-needed $dep $renamed $file
        fi
    done

    soname=$(patchelf --print-soname $file)
    soname_renamed=$(echo $soname | sed -r 's/\.so.*/\.so/')
    if [[ "$soname" != "$soname_renamed" ]]; then
        patchelf --set-soname $soname_renamed $file
    fi
done