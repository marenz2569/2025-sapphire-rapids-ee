# new CMake project, initially only for x86, which compiles the C-files in src to a binary
cmake_minimum_required(VERSION 3.10)

project(atomic-latencies)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Werror -Wall -Wextra -pedantic -O2")

add_executable(atomic-latencies
    src/latency.c
)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

target_link_libraries(atomic-latencies PRIVATE
    Threads::Threads
)