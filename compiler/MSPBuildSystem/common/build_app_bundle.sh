if [ "$1" != "skiplipo" ]; then
    # bundle arch-specific libraries
    cd ${X86_64_BUILD_FOLDER}
    dylibbundler -of -cd -b -x "./${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/

    cd ..
    cd ${ARM64_BUILD_FOLDER}
    dylibbundler -of -cd -b -x "./${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/

    cd ..
fi

# remove any existing app bundle
echo rm -rf "./${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"
rm -rf "./${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"

# make the app bundle directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" || exit 1;
fi
if [ ! -d "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" || exit 1;
fi

echo -n ${PKGINFO} > "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/PkgInfo" || exit 1;

if [ "$1" != "skiplipo" ]; then
    #lipo the executable
    lipo "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -create

    #copy resources
    mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}"
    cp -a "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}"

    mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}"
    cp -a "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}"

    cp -a "${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/." "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi

# doing the icons last in case we need to overwrite theirs
#cp "${ICONSDIR}/${ICONS}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}" || exit 1;

echo "bundle done."