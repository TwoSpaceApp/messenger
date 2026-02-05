cmake_minimum_required(VERSION 3.10)

project(NativeThroat LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(
    NativeThroat
    "native_throat.cpp"
    "native_throat.h"
)

target_include_directories(NativeThroat PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")
