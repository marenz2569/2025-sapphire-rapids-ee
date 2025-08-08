add_measurement(
    NAME shared-frequency-domains-active
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run_active.sh
)

set_property(TEST measurement/shared-frequency-domains-active APPEND PROPERTY ENVIRONMENT WHILE_TRUE=$<TARGET_FILE:while-true>)

add_measurement(
    NAME shared-frequency-domains-idle
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run_idle.sh
)

set_property(TEST measurement/shared-frequency-domains-idle APPEND PROPERTY ENVIRONMENT WHILE_TRUE=$<TARGET_FILE:while-true>)