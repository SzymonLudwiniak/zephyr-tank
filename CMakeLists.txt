cmake_minimum_required(VERSION 3.20.0)

option(BUILD_TESTING "Build tests" OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(BASIC_COMPILE_OPTIONS
    -Wall
    -Werror
)

if(NOT BUILD_TESTING)
    find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
    
    if(BOARD STREQUAL "stm32h747i_disco" AND CHIP STREQUAL "m4")
        project(tank-m4)
        target_sources(app PRIVATE main_m4.cpp)
        # target_link_libraries(app ...)
    elseif(BOARD STREQUAL "stm32h747i_disco" AND CHIP STREQUAL "m7")
        project(tank-m7)
        target_sources(app PRIVATE main_m7.cpp)
        target_link_libraries(app 
            PUBLIC
            )
    else()
        message(FATAL_ERROR "-- Wrong target, aborting...")
    endif()

    enable_language(C CXX ASM)
    set(CMAKE_C_STANDARD 11)
    set(CMAKE_C_STANDARD_REQUIRED ON)
    set(CMAKE_C_EXTENSIONS ON)
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS ON)

    # skip some warnings caused by Zephyr itself
    add_compile_options(
        ${BASIC_COMPILE_OPTIONS}
        -Wno-unused-parameter
        -Wno-missing-field-initializers
    )

    add_subdirectory(src EXCLUDE_FROM_ALL)

else()

    project(UnitTests)

    set(CMAKE_CXX_STANDARD 17)

    enable_testing()

    add_compile_options(${BASIC_COMPILE_OPTIONS})

    add_subdirectory(src EXCLUDE_FROM_ALL)
    add_subdirectory(testing)

endif()

add_subdirectory(etl SYSTEM)
