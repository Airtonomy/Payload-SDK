set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

### CONFIGURE OSAL HEADERS, and static-compile a library
set(OSAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/samples/sample_c++/platform/linux/common)
set(OSAL_DIR ${OSAL_INCLUDE_DIRS}/osal)
file(GLOB MODULE_OSAL_SRCS ${OSAL_DIR}/*.c)
file(GLOB OSAL_INCS ${OSAL_DIR}/*.h)

add_library(OSAL STATIC ${MODULE_OSAL_SRCS})
target_include_directories(OSAL PUBLIC 
    $<BUILD_INTERFACE:${OSAL_DIR}>
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/psdk_lib/include>
$<INSTALL_INTERFACE:include/PayloadSDK>)
set_target_properties(OSAL PROPERTIES PUBLIC_HEADER "${OSAL_INCS}")
target_link_libraries(OSAL PRIVATE Threads::Threads)


set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})
message("Current Module Path ${CMAKE_MODULE_PATH}")
# find_package(LIBUSB REQUIRED) # will use ${PROJECT_SOURCE_DIR}/FindLibUSB.cmake to set this...
# because of how nix works, we don't have to search for c-libs

add_definitions(-DLIBUSB_INSTALLED)


# TODO: change include dir based on platform ( i.e. likely need aarch64 vs amd64)
set(HAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/samples/sample_c++/platform/linux/manifold2)
set(HAL_DIR ${HAL_INCLUDE_DIRS}/hal)
file(GLOB MODULE_HAL_SRCS ${HAL_DIR}/*.c)
file(GLOB HAL_INCS ${HAL_DIR}/*.h)
add_library(HAL STATIC ${MODULE_HAL_SRCS})
target_include_directories(HAL PUBLIC
        $<BUILD_INTERFACE:${HAL_DIR}>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/psdk_lib/include>
        $<INSTALL_INTERFACE:include/PayloadSDK>
        )
set_target_properties(HAL PROPERTIES PUBLIC_HEADER "${HAL_INCS}")
# TODO: in config.cmake, find libUSB and provide the package that way....
# That way we don't have to Explicitly link in downstream dependencies :smile:
target_link_libraries(HAL PUBLIC)

install(TARGETS HAL OSAL
    EXPORT OsalHalTargets
    ARCHIVE DESTINATION lib 
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
    PUBLIC_HEADER DESTINATION include/PayloadSDK # slightly easier to work with
)

# Install Target Export OsalHalTargets to file OsalHalTargets.cmake
# Namespace all targets exported this way as PayloadSDK::myExportedTarget
# Ex. to include OSAL and HAL support, do target_link_libraries(myTarget PayloadSDK::PayloadSDK_HAL)
install(
    EXPORT 
        OsalHalTargets
    FILE 
        OsalHalTargets.cmake
    NAMESPACE
        PayloadSDK::
    DESTINATION
        lib/cmake/PayloadSDK
    )

install(
    FILES
        cmake/OsalHalConfig.cmake
    DESTINATION
        lib/cmake/PayloadSDK
)