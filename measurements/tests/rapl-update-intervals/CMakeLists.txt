add_measurement(
    NAME rapl-update-intervals
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

set_property(TEST measurement/rapl-update-intervals APPEND PROPERTY ENVIRONMENT RAPL_UPDATE_INTERVALS=$<TARGET_FILE:rapl-update-intervals>)