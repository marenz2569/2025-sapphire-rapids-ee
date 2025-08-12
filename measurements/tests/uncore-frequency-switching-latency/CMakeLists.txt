add_measurement(
    NAME uncore-frequency-switching-latency
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

set_property(TEST measurement/uncore-frequency-switching-latency APPEND PROPERTY ENVIRONMENT UFS_MANUAL=$<TARGET_FILE:uncore-frequency-manual-switching-latency>)

set_property(TEST measurement/uncore-frequency-switching-latency APPEND PROPERTY ENVIRONMENT UFS_AUTOMATIC=$<TARGET_FILE:uncore-frequency-automatic-switching-latency>)