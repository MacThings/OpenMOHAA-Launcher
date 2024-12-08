# softwareupdate --install-rosetta
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# brew install sdl2 openal-soft bison ninja git cmake
# arch -x86_64 /usr/local/bin/brew install sdl2 openal-soft

export PATH="/opt/homebrew/bin:$PATH"

# game/app specific values
export PRODUCT_NAME="openmohaa"
export PROJECT_NAME="openmohaa"
export EXECUTABLE_NAME="openmohaa"
export EXECUTABLE_SERVER_NAME="omohaaded"
export GIT_DEFAULT_BRANCH="main"
# constants
export BUILT_PRODUCTS_DIR="release"
export WRAPPER_NAME="${PRODUCT_NAME}.app"
export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
export ARM64_BUILD_FOLDER="build-arm64"
export ARM64_LIBS_FOLDER="libs-arm64"
export X86_64_BUILD_FOLDER="build-x86_64"
export X86_64_LIBS_FOLDER="libs-x86_64"

set -e

if [ ! -d openmohaa ]; then
    git clone https://github.com/openmoh/openmohaa openmohaa
fi

cd ${PROJECT_NAME}

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest
echo git pull
git pull

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

cp CMakeLists.txt CMakeLists.txt_ori

echo '
find_package(SDL2 REQUIRED)
if(SDL2_FOUND)
    include_directories(${SDL2_INCLUDE_DIRS})
    target_link_libraries(openmohaa PRIVATE ${SDL2_LIBRARIES})
else()
    message(FATAL_ERROR "SDL2 not found")
endif()
' >> CMakeLists.txt

export MACOSX_DEPLOYMENT_TARGET=10.15

cd ${X86_64_BUILD_FOLDER}

cmake -G Ninja \
-DOPENAL_INCLUDE_DIR=/usr/local/opt/openal-soft/include/AL \
-DCMAKE_OSX_ARCHITECTURES=x86_64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
../
ninja
mkdir -p "${EXECUTABLE_FOLDER_PATH}"
cp openmohaa.x86_64 "${EXECUTABLE_FOLDER_PATH}"/"${EXECUTABLE_NAME}"
cp omohaaded.x86_64 "${EXECUTABLE_FOLDER_PATH}"/omohaaded
cp code/client/cgame/cgame.x86_64.dylib "${EXECUTABLE_FOLDER_PATH}"
cp code/server/fgame/game.x86_64.dylib "${EXECUTABLE_FOLDER_PATH}"

cd ../${ARM64_BUILD_FOLDER}

cmake -G Ninja \
-DOPENAL_INCLUDE_DIR=/opt/Homebrew/opt/openal-soft/include/AL \
-DCMAKE_OSX_ARCHITECTURES=arm64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=11.5 \
-DCMAKE_PREFIX_PATH=/opt/Homebrew \
-DCMAKE_INSTALL_PREFIX=/opt/Homebrew \
../
ninja
mkdir -p "${EXECUTABLE_FOLDER_PATH}"
cp openmohaa.arm64 "${EXECUTABLE_FOLDER_PATH}"/"${EXECUTABLE_NAME}"
cp omohaaded.arm64 "${EXECUTABLE_FOLDER_PATH}"/omohaaded
cp code/client/cgame/cgame.arm64.dylib "${EXECUTABLE_FOLDER_PATH}"
cp code/server/fgame/game.arm64.dylib "${EXECUTABLE_FOLDER_PATH}"
cd ..

rm CMakeLists.txt
mv CMakeLists.txt_ori CMakeLists.txt

cd "../../OpenMOHAA Launcher/bin"

lipo ../../compiler/openmohaa/build-x86_64/code/client/cgame/cgame.x86_64.dylib \
../../compiler/openmohaa/build-arm64/code/client/cgame/cgame.arm64.dylib -output cgame.dylib -create

lipo ../../compiler/openmohaa/build-x86_64/code/server/fgame/game.x86_64.dylib \
../../compiler/openmohaa/build-arm64/code/server/fgame/game.arm64.dylib -output game.dylib -create

lipo ../../compiler/openmohaa/build-x86_64/openmohaa.x86_64 \
../../compiler/openmohaa/build-arm64/openmohaa.arm64 -output openmohaa -create

lipo ../../compiler/openmohaa/build-x86_64/omohaaded.x86_64 \
../../compiler/openmohaa/build-arm64/omohaaded.arm64 -output omohaaded -create

lipo /usr/local/opt/openal-soft/lib/libopenal.1.dylib /opt/Homebrew/opt/openal-soft/lib/libopenal.1.dylib -output libopenal.1.dylib -create

lipo /usr/local/lib/libSDL2-2.0.0.dylib /opt/homebrew/lib/libSDL2-2.0.0.dylib -output libSDL2-2.0.0.dylib -create

install_name_tool -change "@rpath/SDL2.framework/Versions/A/SDL2" "@rpath/libSDL2-2.0.0.dylib" openmohaa

