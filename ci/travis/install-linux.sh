#!/usr/bin/env bash

set -e
# dump env
printenv

JOBS=$(cat /proc/cpuinfo | grep '^processor' | wc -l)
export MAKEFLAGS="-j${JOBS}"

# CMake
build_cmake()
{
    echo "Prepare CMake"

    local CMAKE_VERSION_BASE=3.27
    local CMAKE_VERSION_MINOR=0
    local CMAKE_VERSION_FULL=${CMAKE_VERSION_BASE}.${CMAKE_VERSION_MINOR}
    local CMAKE_ARCH=x86_64
    local CMAKE_OS=linux

    #wget -c http://www.cmake.org/files/v${CMAKE_VERSION_BASE}/cmake-${CMAKE_VERSION_FULL}.tar.gz
    #tar -xzf cmake-${CMAKE_VERSION_FULL}.tar.gz
    #cd cmake-${CMAKE_VERSION_FULL}/
    #./configure --prefix=/usr
    #make
    #sudo make install

    wget -c https://cmake.org/files/v${CMAKE_VERSION_BASE}/cmake-${CMAKE_VERSION_FULL}-${CMAKE_OS}-${CMAKE_ARCH}.tar.gz
    tar -xzf cmake-${CMAKE_VERSION_FULL}-${CMAKE_OS}-${CMAKE_ARCH}.tar.gz
    export PATH=$(pwd)/cmake-${CMAKE_VERSION_FULL}-${CMAKE_OS}-${CMAKE_ARCH}/bin:$PATH
    cmake --version
}

build_cmake

# Newer GCC
#if [ -n "$MATRIX_EVAL" ]; then
#    echo "Prepare GCC"
#    sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
#    sudo apt-get -qq update
#    (
#        eval "${MATRIX_EVAL}"
#        case "${CXX}" in
#            g++-5)
#                pkg='g\+\+-5'
#            ;;
#            g++-6)
#                pkg='g\+\+-6'
#            ;;
#            g++-7)
#                pkg='g\+\+-7'
#            ;;
#            *)
#                echo "Unknown compiler: ${CXX}"
#                exit 1
#            ;;
#        esac
#        #sudo apt-get install -y 'g\+\+-5' 'g\+\+-6' 'g\+\+-7'
#        sudo apt-get install -y "${pkg}"
#    )
#fi

# FFmpeg
# - https://launchpad.net/~jonathonf/+archive/ubuntu/ffmpeg-4
echo "Prepare FFmpeg"
(
    # Xenial has no FFmpeg yet
    if [ "$TRAVIS_DIST" = "xenial" -o "$OS_NAME" = "ubuntu-16.04" ]; then
        sudo add-apt-repository ppa:jonathonf/ffmpeg-4 -y
        sudo apt-get -qq update
    fi

    sudo apt-get install -y libavcodec-dev \
                            libavdevice-dev \
                            libavfilter-dev \
                            libavformat-dev \
                            libavutil-dev \
                            libpostproc-dev \
                            libswscale-dev \
                            libswresample-dev
    # fail silently
    sudo apt-get install -y libavresample-dev || true
)

if [ -z "$SKIP_MESON" -o "$SKIP_MESON" = "false" ]; then
    echo "Prepare Meson"
    (
        sudo apt-get install -y python3-pip python3-setuptools  ninja-build
        sudo -H python3 -m pip install meson
    )
fi

set +e
