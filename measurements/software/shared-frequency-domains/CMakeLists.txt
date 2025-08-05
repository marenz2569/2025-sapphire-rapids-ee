add_test_with_output(
    NAME shared-frequency-domains
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

ExternalProject_Get_Property(while-true BINARY_DIR)
set_property(TEST shared-frequency-domains APPEND PROPERTY ENVIRONMENT WHILE_TRUE=${BINARY_DIR}/while-true)