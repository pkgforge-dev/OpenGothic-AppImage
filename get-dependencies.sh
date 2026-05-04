#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake          \
    glslang        \
    glu            \
    vulkan-headers

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
#echo "Making nightly build of OpenGothic..."
#echo "---------------------------------------------------------------"
#REPO="https://github.com/Try/OpenGothic"
#VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
#git clone --recursive --depth 1 "$REPO" ./OpenGothic
#echo "$VERSION" > ~/version
echo "Building OpenGothic..."
echo "---------------------------------------------------------------"
mkdir -p ./AppDir/bin
git clone --recursive --depth 1 https://github.com/Try/OpenGothic ./OpenGothic
cd ./OpenGothic
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build..."
    git rev-parse --short HEAD > ~/version
else
    echo "Making stable build of OpenGothic..."
    echo "---------------------------------------------------------------"
    git fetch --tags --depth 1
    RAW_TAG=$(git tag -l "opengothic-v*" | sort -V | tail -n 1)
    git checkout "$RAW_TAG"
    echo "$RAW_TAG" | sed 's/opengothic-v//' > ~/version
fi

#mkdir -p ./AppDir/bin
#cd ./OpenGothic
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-Wno-error=stringop-overflow" ..
make -j$(nproc)
mv -v opengothic/Gothic2Notr ../../AppDir/bin
if [ ! "${DEVEL_RELEASE-}" = 1 ]; then
    #mv -v ./OpenGothic/build/opengothic/libTempest.so ../../AppDir/bin
    mv -v opengothic/libTempest.so ../../AppDir/bin
fi
