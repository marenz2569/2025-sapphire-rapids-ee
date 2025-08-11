add_measurement(
    NAME core-layout
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

set_tests_properties(measurement/core-layout PROPERTIES TIMEOUT 1200)

ExternalProject_Get_Property(stream INSTALL_DIR)
set_property(TEST measurement/core-layout APPEND PROPERTY ENVIRONMENT STREAM=${INSTALL_DIR}/stream)