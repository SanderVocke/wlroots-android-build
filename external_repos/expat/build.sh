SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
export TARGET=${ANDROID_TARGET}
export API=${ANDROID_API}
export AR=$TOOLCHAIN/bin/llvm-ar
export CC=$TOOLCHAIN/bin/$TARGET$API-clang
export AS=$CC
export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

# Build and install to artifacts
ARTIFACTS=${SCRIPT_DIR}/../../artifacts/${ARTIFACTS}/${ANDROID_ARCH}
mkdir -p ${ARTIFACTS}
pushd libffi
./buildconf.sh
./configure --host ${TARGET} --prefix=${ARTIFACTS}
make
make install
popd