cmake_minimum_required(VERSION 2.8)

if (NOT USE_SYSTEM_ARCH)
    # select use platform 'LINUX' or 'RTOS' here, reset cache and reload cmake project
    set(USE_SYSTEM_ARCH LINUX)
endif ()

if (USE_SYSTEM_ARCH MATCHES RTOS)
    cmake_minimum_required(VERSION 3.15)
    set(CMAKE_C_COMPILER arm-none-eabi-gcc)
    set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
    set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)
    set(CMAKE_AR arm-none-eabi-ar)
    set(CMAKE_OBJCOPY arm-none-eabi-objcopy)
    set(CMAKE_OBJDUMP arm-none-eabi-objdump)
    set(SIZE arm-none-eabi-size)
    set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
endif ()

option(DJI_BUILD_SAMPLES "Build the sample scripts available to your platform" OFF)

project(entry)

# Disable in-source builds to prevent source tree corruption.
if (" ${CMAKE_SOURCE_DIR}" STREQUAL " ${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR "FATAL: In-source builds are not allowed.
       You should create a separate directory for build files.")
endif ()



if (USE_SYSTEM_ARCH MATCHES LINUX)
    add_definitions(-DSYSTEM_ARCH_LINUX)
    if(DJI_BUILD_SAMPLES)
        add_subdirectory(samples/sample_c/platform/linux/manifold2)
        add_subdirectory(samples/sample_c++/platform/linux/manifold2)
    endif()

    execute_process(COMMAND uname -m OUTPUT_VARIABLE DEVICE_SYSTEM_ID)
    if (DEVICE_SYSTEM_ID MATCHES x86_64)
        set(LIBRARY_PATH psdk_lib/lib/x86_64-linux-gnu-gcc)
    elseif (DEVICE_SYSTEM_ID MATCHES aarch64)
        set(LIBRARY_PATH psdk_lib/lib/aarch64-linux-gnu-gcc)
    else ()
        message(FATAL_ERROR "FATAL: Please confirm your platform.")
    endif ()
    
    
    # Installing a directory gets a global include path... not ideal lol
    file(GLOB PayloadSDK_INCLUDES "psdk_lib/include/*.h")
    install(FILES ${PayloadSDK_INCLUDES}
            DESTINATION "include/PayloadSDK"
            )

    install(FILES ${LIBRARY_PATH}/libpayloadsdk.a
            DESTINATION "lib"
            )

    # Configure files for find_package
    configure_file(
        ${PROJECT_SOURCE_DIR}/pkg/payloadsdk-config.cmake.in
        ${PROJECT_BINARY_DIR}/pkg/payloadsdk-config.cmake
                   @ONLY)            

    install(FILES ${PROJECT_BINARY_DIR}/pkg/payloadsdk-config.cmake
            DESTINATION lib/cmake/PayloadSDK)

    include(${PROJECT_SOURCE_DIR}/payloadsdk_hal_osal.cmake)

    # TODO make optional env version
    set(CPACK_PACKAGE_NAME "PayloadSDK")
    set(CPACK_PACKAGE_VERSION $ENV{VERSION})

    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libusb-1.0-0,libopencv-dev,ffmpeg,libopus0")
    set(CPACK_GENERATOR "DEB")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "dev@airtonomy.ai") #required
    include(CPack)


elseif (USE_SYSTEM_ARCH MATCHES RTOS)
    add_definitions(-DSYSTEM_ARCH_RTOS)
    add_subdirectory(samples/sample_c/platform/rtos_freertos/stm32f4_discovery/project/armgcc)
endif ()

add_custom_target(${PROJECT_NAME} ALL)
