#!/bin/bash

readonly PROJECT_ROOT=$(pwd)
readonly STM_BOARD="stm32f429i_disc1"
readonly BUILD_PATH="${PROJECT_ROOT}/build"
readonly BUILD_PATH_TEST="${PROJECT_ROOT}/build_test"

clean() {
    rm -rf $BUILD_PATH/*
    rm -rf $BUILD_PATH_TEST/*
}

build_stm() {
    mkdir -p $BUILD_PATH/$STM_BOARD
    west build -b $STM_BOARD $PROJECT_ROOT --build-dir $BUILD_PATH/$STM_BOARD
}

test() {
    
    mkdir -p ${BUILD_PATH_TEST}
    cd ${BUILD_PATH_TEST}
    cmake -DBUILD_TESTING=ON ${PROJECT_ROOT}

    # Run build tool if CMake generation finished successfully 
    if [ $? -eq 0 ]; then
        cmake --build .
    fi
    
    if [ $? -eq 0 ]; then
        ctest
    fi

}

flash_stm() {
    west flash -d $BUILD_PATH/$STM_BOARD
}

help() {
    local message="Supported commands\n"
    message+="-b, --build\tbuild target for stm32f429 disc1\n"
    message+="-f, --flash\tflash stm32f429 disc1\n"
    message+="-t, --test\t\ttest project\n"
    message+="-c, --clean\t\tclean the current build\n"

    echo -e ${message}
}

main() {
    local -r command=$1
    case ${command} in
        -b|--build)
            build_stm
        ;;
        -t|--test)
            test
        ;;
        -f|--flash)
            flash_stm
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
