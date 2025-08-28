find_package(Python REQUIRED)

add_measurement(
    NAME core-to-core-latency
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.py
)

set_property(TEST measurement/core-to-core-latency APPEND PROPERTY ENVIRONMENT ATOMIC_LATENCIES=$<TARGET_FILE:atomic-latencies>)

add_notebook(
    NAME core-to-core-latency
    FILE ${CMAKE_CURRENT_SOURCE_DIR}/PlotAll.ipynb
)