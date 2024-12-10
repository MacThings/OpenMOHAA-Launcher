# softwareupdate --install-rosetta
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# brew install sdl2 openal-soft bison ninja git cmake
# arch -x86_64 /usr/local/bin/brew install sdl2 openal-soft

set -e  # Skript bei Fehlern beenden

export PATH="/opt/homebrew/bin:$PATH"

# Repository klonen, falls es nicht existiert
if [ ! -d openmohaa ]; then
    git clone https://github.com/openmoh/openmohaa openmohaa
fi

cd openmohaa

# Auf den Hauptbranch zurücksetzen und aktualisieren
git checkout main
git pull

# Build-Verzeichnisse bereinigen und neu erstellen
for ARCH in x86_64 arm64; do
    rm -rf "build-${ARCH}"
    mkdir "build-${ARCH}"
done

# SDL2-Variablen finden
SDL2_INCLUDE_DIR=$(sdl2-config --cflags | sed 's/-I//g')
SDL2_LIBRARY=$(sdl2-config --libs | awk '{print $1}' | sed 's/-l//')

# Build für beide Architekturen
build_arch() {
    local ARCH=$1
    local DEPLOYMENT_TARGET=$2
    local PREFIX_PATH=$3
    local OPENAL_INCLUDE=$4

    cd "build-${ARCH}"

    cmake -G Ninja \
        -DOPENAL_INCLUDE_DIR="${OPENAL_INCLUDE}" \
        -DCMAKE_OSX_ARCHITECTURES="${ARCH}" \
        -DCMAKE_OSX_DEPLOYMENT_TARGET="${DEPLOYMENT_TARGET}" \
        -DCMAKE_PREFIX_PATH="${PREFIX_PATH}" \
        -DCMAKE_INSTALL_PREFIX="${PREFIX_PATH}" \
        -DSDL2_INCLUDE_DIRS="${SDL2_INCLUDE_DIR}" \
        -DSDL2_LIBRARIES="${SDL2_LIBRARY}" \
        ..
    ninja
    cd ..
}

# x86_64-Build
build_arch x86_64 10.15 /usr/local /usr/local/opt/openal-soft/include/AL

# arm64-Build
build_arch arm64 11.5 /opt/Homebrew /opt/Homebrew/opt/openal-soft/include/AL

# Fat Binaries erstellen
cd "../../OpenMOHAA Launcher/bin"

create_fat_binary() {
    local OUTPUT=$1
    shift
    lipo -create "$@" -output "${OUTPUT}"
}

create_fat_binary cgame.dylib \
    ../../compiler/openmohaa/build-x86_64/code/client/cgame/cgame.x86_64.dylib \
    ../../compiler/openmohaa/build-arm64/code/client/cgame/cgame.arm64.dylib

create_fat_binary game.dylib \
    ../../compiler/openmohaa/build-x86_64/code/server/fgame/game.x86_64.dylib \
    ../../compiler/openmohaa/build-arm64/code/server/fgame/game.arm64.dylib

create_fat_binary openmohaa \
    ../../compiler/openmohaa/build-x86_64/openmohaa.x86_64 \
    ../../compiler/openmohaa/build-arm64/openmohaa.arm64

create_fat_binary omohaaded \
    ../../compiler/openmohaa/build-x86_64/omohaaded.x86_64 \
    ../../compiler/openmohaa/build-arm64/omohaaded.arm64

create_fat_binary libopenal.1.dylib \
    /usr/local/opt/openal-soft/lib/libopenal.1.dylib \
    /opt/Homebrew/opt/openal-soft/lib/libopenal.1.dylib

create_fat_binary libSDL2-2.0.0.dylib \
    /usr/local/lib/libSDL2-2.0.0.dylib \
    /opt/homebrew/lib/libSDL2-2.0.0.dylib

# SDL2-Pfad in der ausführbaren Datei ändern
install_name_tool -change "@rpath/SDL2.framework/Versions/A/SDL2" "@rpath/libSDL2-2.0.0.dylib" openmohaa
