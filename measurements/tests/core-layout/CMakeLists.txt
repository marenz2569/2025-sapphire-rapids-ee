add_measurement(
    NAME core-layout
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

set_tests_properties(measurement/core-layout PROPERTIES TIMEOUT 1200)

set_property(TEST measurement/core-layout APPEND PROPERTY ENVIRONMENT STREAM=$<TARGET_FILE:stream>)