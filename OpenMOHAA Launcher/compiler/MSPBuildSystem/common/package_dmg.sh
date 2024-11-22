#move app bundle to a subfolder
mkdir -p ${BUILT_PRODUCTS_DIR}/source_folder
mv "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}" ${BUILT_PRODUCTS_DIR}/source_folder


#move app bundle back to parent folder
echo mv "${BUILT_PRODUCTS_DIR}/source_folder/${WRAPPER_NAME}" ${BUILT_PRODUCTS_DIR}
mv "${BUILT_PRODUCTS_DIR}/source_folder/${WRAPPER_NAME}" ${BUILT_PRODUCTS_DIR}
rm -rd ${BUILT_PRODUCTS_DIR}/source_folder

if [ "$1" != "skipdelete" ]; then
  if [ -d "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}_${DATE_TIMESTAMP}" ]; then
    rm -rf "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}_${DATE_TIMESTAMP}" || exit 1;
  fi
  mkdir -p "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}_${DATE_TIMESTAMP}";
fi

rm -rf ${BUILT_PRODUCTS_DIR}/openmohaa.app/Contents/MacOS/libs-*
cp -a ${BUILT_PRODUCTS_DIR}/openmohaa.app/Contents/MacOS/* "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}_${DATE_TIMESTAMP}"

if [ "$1" != "skipcleanup" ] && [ "$2" != "skipcleanup" ]; then
    echo "Cleaning up"
    rm -rf ${X86_64_BUILD_FOLDER}
    rm -rf ${ARM64_BUILD_FOLDER}
    rm -rf ${BUILT_PRODUCTS_DIR}
else 
    echo "Skipping cleanup"
fi