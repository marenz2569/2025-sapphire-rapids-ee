add_test_with_output(
    NAME shared-frequency-domains
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

set_property(TEST shared-frequency-domains APPEND PROPERTY ENVIRONMENT WHILE_TRUE=$<TARGET_FILE:while-true>)