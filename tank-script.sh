#!/bin/bash

readonly PROJECT_ROOT=$(pwd)
readonly M4_BOARD="stm32h747i_disco_m4"
readonly M7_BOARD="stm32h747i_disco_m7"
readonly BUILD_PATH="${PROJECT_ROOT}/build"
readonly RUNNER="openocd"

clean() {
    rm -rf $BUILD_PATH/*
}

build_m4() {
    mkdir -p $BUILD_PATH/$M4_BOARD
    west build -b $M4_BOARD $PROJECT_ROOT --build-dir $BUILD_PATH/$M4_BOARD -D CHIP=m4
}

build_m7() {
    mkdir -p $BUILD_PATH/$M7_BOARD
    west build -b $M7_BOARD $PROJECT_ROOT --build-dir $BUILD_PATH/$M7_BOARD -D CHIP=m7
}

test() {
    local -r build_test_dir="${PROJECT_ROOT}/build_test"
    
    mkdir -p ${build_test_dir}
    cd ${build_test_dir}
    cmake -DBUILD_TESTING=ON ${PROJECT_ROOT}

    # Run build tool if CMake generation finished successfully 
    if [ $? -eq 0 ]; then
        cmake --build .
    fi
    
    if [ $? -eq 0 ]; then
        ctest
    fi

}

flash_m4() {
    west flash -d $BUILD_PATH/$M4_BOARD --runner $RUNNER
}

flash_m7() {
    west flash -d $BUILD_PATH/$M7_BOARD --runner $RUNNER
}

help() {
    local message="**SUPPORTED COMMANDS**\n\n"
    message+="-b,\t--build\t\tbuild both targets\n"
    message+="-bm4,\t--build_m4\tbuild target for cortex-m4\n"
    message+="-bm7,\t--build_m7\tbuild target for cortex-m7\n"
    message+="-f,\t--flash\t\tflash both targets\n"
    message+="-fm4,\t--flash_m4\tflash cortex-m4\n"
    message+="-fm7,\t--flash_m7\tflash cortex-m7\n"
    message+="-t,\t--test\t\ttest project\n"
    message+="-c,\t--clean\t\tclean the current build\n"

    echo -e ${message}
}

main() {
    local -r command=$1
    case ${command} in
        -b|--build)
            build_m4
            build_m7
        ;;
        -bm4|--build_m4)
            build_m4
        ;;
        -bm7|--build_m7)
            build_m7
        ;;
        -t|--test)
            test
        ;;
        -f|--flash)
            flash_m4
            flash_m7
        ;;
        -fm4|--flash_m4)
            flash_m4
        ;;
        -fm7|--flash_m7)
            flash_m7
        ;;
        -c|--clean)
            clean
        ;;
        -h|--help)
            help
        ;;
        *)
            echo "Unknown argument: [$command]"
            help
        ;;
    esac
}

main $@
