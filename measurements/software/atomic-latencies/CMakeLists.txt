# new CMake project, initially only for x86, which compiles the C-files in src to a binary
cmake_minimum_required(VERSION 3.10)
project(LatencyBenchmark)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -pedantic -O2")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pthread -lm")
set(CMAKE_BUILD_TYPE Release)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
add_executable(latency_benchmark src/latency.c)
# Add the source files
target_sources(latency_benchmark PRIVATE
    src/latency.c
)
