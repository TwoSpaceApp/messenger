cmake_minimum_required(VERSION 3.10)

project(runner LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Project files
add_executable(
  runner
  "main.cpp"
  "flutter_window.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "win32_window.h"
  "resource.h"
  "runner.rc"
)

# Add the NativeThroat library
add_subdirectory(NativeThroat)

# Link the runner to the NativeThroat library
target_link_libraries(runner PRIVATE NativeThroat)

# Flutter
set(FLUTTER_PROJECT_DIR "${CMAKE_SOURCE_DIR}/../..")
add_subdirectory(
  "${FLUTTER_PROJECT_DIR}/flutter"
  "${CMAKE_BINARY_DIR}/flutter"
)

target_link_libraries(
  runner
  PRIVATE
  flutter
  flutter_wrapper_app
)
