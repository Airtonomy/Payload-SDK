
message("Configuring CPack for debian packaging")

file(READ "psdk_lib/include/dji_version.h" SDK_VERSION)
set(VERSION_REGEX "[0-9]+")
string(REGEX MATCH "#define DJI_VERSION_MAJOR[ \t]+[0-9]+" DEF_VERSION "${SDK_VERSION}")
string(REGEX MATCH "${VERSION_REGEX}" VERSION_MAJOR "${DEF_VERSION}")

string(REGEX MATCH "#define DJI_VERSION_MINOR[ \t]+[0-9]+" DEF_VERSION "${SDK_VERSION}")
string(REGEX MATCH "${VERSION_REGEX}" VERSION_MINOR "${DEF_VERSION}")

string(REGEX MATCH "#define DJI_VERSION_MODIFY[ \t]+[0-9]+" DEF_VERSION "${SDK_VERSION}")
string(REGEX MATCH "${VERSION_REGEX}" VERSION_PATCH "${DEF_VERSION}")

set(PACKAGE_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")
message("PayloadSDK Version set too: ${PACKAGE_VERSION}")

set(CPACK_PACKAGE_NAME "PayloadSDK")
set(CPACK_PACKAGE_VERSION "${PACKAGE_VERSION}")

# hal_network.h currently directly utilizes shell command `ifconfig` instead of sys-libs
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libusb-1.0-0,libopencv-dev,ffmpeg,libopus0,net-tools")
set(CPACK_GENERATOR "DEB")
set(CPACK_DEBIAN_PACKAGE_DESCRIPTION "The Payload-SDK Library")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "dev@airtonomy.ai") #required

include(CPack)