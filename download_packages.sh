#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PACKAGES="liblzma \
libcrypt \
libxml2 \
openssl \
libpixman \
libexpat \
libffi \
zlib \
libandroid-shmem
"
BASE_URL="https://packages.termux.org/apt/termux-main/pool/main"

rm -r ${SCRIPT_DIR}/prebuilt

for package in ${PACKAGES}; do
    echo "Downloading package: $package"
    # Get the prefix in the package repo, e.g.
    # c/, l/ or libc/, libl/
    if [ "$(echo ${package} | cut -c -3)" = "lib" ]; then
        PACKAGE_PREFIX=$(echo ${package} | cut -c 1-4)
    else
        PACKAGE_PREFIX=$(echo ${package} | cut -c 1)
    fi

    PACKAGE_VERSION_LIST_URL="${BASE_URL}/${PACKAGE_PREFIX}/${package}"
    PACKAGE_VERSION_LIST_HTML=$(wget -qO- "${PACKAGE_VERSION_LIST_URL}")

    ALL_PACKAGE_FILES="$(echo -e "${PACKAGE_VERSION_LIST_HTML}" \
        | grep -E "\"${package}_.*_.*\\.deb\"" \
        | sed -r "s/.*\"(${package}[^\"]*\\.deb)\".*/\\1/" \
        )"

    ALL_PACKAGE_VERSIONS="$(echo -e "${ALL_PACKAGE_FILES}" \
        | sed -r "s/[^_]*_([^_]+)_.*/\\1/" \
        | sort | uniq
        )"

    LATEST_VERSION="$(echo -e "${ALL_PACKAGE_VERSIONS}" | tail -n1)"

    ALL_ARCHS="$(echo -e "${ALL_PACKAGE_FILES}" \
        | grep "${package}_${LATEST_VERSION}" \
        | sed -r "s/${package}_${LATEST_VERSION}_([^\.]+)\.deb/\\1/" \
        | tr '\n' ' '
        )"

    echo "  - latest version: ${LATEST_VERSION}"
    echo "  - architectures: ${ALL_ARCHS}"

    for arch in ${ALL_ARCHS}; do
        if [ "$arch" = "arm" ]; then
            store_arch="armv7a"
        else
            store_arch=$arch
        fi

        FILENAME="${package}_${LATEST_VERSION}_${arch}.deb"
        wget -q -O /tmp/${FILENAME} "${PACKAGE_VERSION_LIST_URL}/${FILENAME}"

        mkdir -p ${SCRIPT_DIR}/prebuilt/${store_arch}
        mkdir -p /tmp/${FILENAME}.dir/
        dpkg-deb --extract /tmp/${FILENAME} /tmp/${FILENAME}.dir

        cp -r /tmp/${FILENAME}.dir/data/data/com.termux/files/usr/* ${SCRIPT_DIR}/prebuilt/${store_arch}/

        rm -r /tmp/${FILENAME} /tmp/${FILENAME}.dir

        # Fix hard-coded Termux paths in Pkgconfig files.
        sed -i 's/\/data\/data\/com\.termux\/files\/usr/${prefix}/g' ${SCRIPT_DIR}/prebuilt/${store_arch}/lib/pkgconfig/*.pc
    done
done