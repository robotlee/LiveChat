#!/bin/sh
set -e

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=""

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm\""
      xcrun mapc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      XCASSET_FILES="$XCASSET_FILES '${PODS_ROOT}/$1'"
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "XMPPFramework/Extensions/Roster/CoreDataStorage/XMPPRoster.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0045/CoreDataStorage/XMPPRoom.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0045/CoreDataStorage/XMPPRoom.xcdatamodeld/XMPPRoom.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0045/HybridStorage/XMPPRoomHybrid.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0045/HybridStorage/XMPPRoomHybrid.xcdatamodeld/XMPPRoomHybrid.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0054/CoreDataStorage/XMPPvCard.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0054/CoreDataStorage/XMPPvCard.xcdatamodeld/XMPPvCard.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0115/CoreDataStorage/XMPPCapabilities.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0136/CoreDataStorage/XMPPMessageArchiving.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0136/CoreDataStorage/XMPPMessageArchiving.xcdatamodeld/XMPPMessageArchiving.xcdatamodel"
  install_resource "XMPPFramework/Xcode/ServerlessDemo/ServerlessDemo.xcdatamodel"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "XMPPFramework/Extensions/Roster/CoreDataStorage/XMPPRoster.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0045/CoreDataStorage/XMPPRoom.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0045/CoreDataStorage/XMPPRoom.xcdatamodeld/XMPPRoom.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0045/HybridStorage/XMPPRoomHybrid.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0045/HybridStorage/XMPPRoomHybrid.xcdatamodeld/XMPPRoomHybrid.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0054/CoreDataStorage/XMPPvCard.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0054/CoreDataStorage/XMPPvCard.xcdatamodeld/XMPPvCard.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0115/CoreDataStorage/XMPPCapabilities.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0136/CoreDataStorage/XMPPMessageArchiving.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0136/CoreDataStorage/XMPPMessageArchiving.xcdatamodeld/XMPPMessageArchiving.xcdatamodel"
  install_resource "XMPPFramework/Xcode/ServerlessDemo/ServerlessDemo.xcdatamodel"
fi

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  case "${TARGETED_DEVICE_FAMILY}" in
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;
  esac
  while read line; do XCASSET_FILES="$XCASSET_FILES '$line'"; done <<<$(find "$PWD" -name "*.xcassets" | egrep -v "^$PODS_ROOT")
  echo $XCASSET_FILES | xargs actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi