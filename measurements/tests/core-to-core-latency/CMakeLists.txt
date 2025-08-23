find_package(Python REQUIRED)

add_measurement(
    NAME core-to-core-latency
    COMMAND ${Python_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/run.py
)

set_property(TEST measurement/core-to-core-latency APPEND PROPERTY ENVIRONMENT ATOMIC_LATENCIES=$<TARGET_FILE:atomic-latencies>)