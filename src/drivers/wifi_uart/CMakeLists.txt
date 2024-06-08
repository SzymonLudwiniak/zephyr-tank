project(WifiUartInterface CXX)

add_library(${PROJECT_NAME} INTERFACE)

target_include_directories(${PROJECT_NAME} INTERFACE
    ${CMAKE_SOURCE_DIR}/include/drivers/wifi_uart/interface
)

# #########################################
project(WifiUart CXX)

add_library(${PROJECT_NAME}
    OBJECT
    wifi_uart.cpp
)

target_include_directories(${PROJECT_NAME} PUBLIC
    ${CMAKE_SOURCE_DIR}/include/drivers/wifi_uart
)

target_link_libraries(${PROJECT_NAME} PUBLIC
    WifiDriverInterface
    zephyr
)
