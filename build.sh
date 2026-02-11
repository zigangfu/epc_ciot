#!/bin/bash
PROJECT_ROOT_DIR=$(dirname `readlink -f $0`)

echo $PROJECT_ROOT_DIR

CROSSCOMPILE=0
REBUILD=0

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --cross)
            CROSSCOMPILE=1
            shift
	    ;;

        -r)
            REBUILD=1
            shift
	    ;;

    	*)
            echo 'ERROR: not support options'
            exit -1
    esac
done

if [ $CROSSCOMPILE -eq 0 ]; then
    MESON_CROSSCOMPILE=""
    CMAKE_CROSSCOMPILE_OPTION=""
    LIBUSB_CROSSCOMPILE_OPTION=""
    openssl_cross_compile_option=""
else
    set -a
    source "$PROJECT_ROOT_DIR/scripts/cross_compile.env"
    set +a
    export PATH=${PATH_TOOLCHAIN_AARCH64}:$PATH
    echo $PATH
    openssl_cross_compile_option="--cross-compile-prefix=aarch64-linux-gnu-"
    MESON_CROSSCOMPILE="--cross-file $PROJECT_ROOT_DIR/scripts/arm64_armv8_linux_gcc"
    CMAKE_CROSSCOMPILE_OPTION="-DCROSSCOMPILE_AARCH64=ON  -DCMAKE_TOOLCHAIN_FILE=$PROJECT_ROOT_DIR/scripts/aarch64.cmake"
    LIBUSB_CROSSCOMPILE_OPTION="--host=aarch64-linux-gnu CC=aarch64-linux-gnu-gcc CXX=aarch64-linux-gnu-g++ AR=aarch64-linux-gnu-ar RANLIB=aarch64-linux-gnu-ranlib STRIP=aarch64-linux-gnu-strip"
fi

# libmbedtls start
THIRD_PARTY_DIR=$PROJECT_ROOT_DIR/third_party
libmbedtls_src_dir=$THIRD_PARTY_DIR/mbedtls
libmbedtls_build_dir=$libmbedtls_src_dir/build
libmbedtls_install_dir="$THIRD_PARTY_DIR/mbedtls-install/"
if [ $REBUILD -eq 1 ] || [ ! -d $libmbedtls_install_dir ]; then
  if [ -d $libmbedtls_build_dir ]; then
	rm -rf $libmbedtls_build_dir
  fi
  if [ -d $libmbedtls_install_dir ]; then
    rm -rf $libmbedtls_install_dir
  fi

  echo "build libmbedtls"
  build_type="Release"

  mkdir $libmbedtls_build_dir
  cd $libmbedtls_build_dir

  cmake -DCMAKE_BUILD_TYPE=$build_type ${CMAKE_CROSSCOMPILE_OPTION} -DCMAKE_INSTALL_PREFIX=$libmbedtls_install_dir -DENABLE_FLOAT=ON -DBUILD_SHARED_LIBS=OFF ..
  make -j${JOB_NUM} && make install
  if [ $? -ne 0 ];then
  	exit -1
  fi
fi 
# libmbedtls end

cd $PROJECT_ROOT_DIR
build_type="debug"

rm -rf build
meson $MESON_CROSSCOMPILE --buildtype=$build_type build
cd build
meson compile
