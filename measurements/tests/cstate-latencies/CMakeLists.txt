add_measurement(
    NAME cstate-latencies
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

# 1 day
set_tests_properties(measurement/cstate-latencies PROPERTIES TIMEOUT 86400)

set_property(TEST measurement/cstate-latencies APPEND PROPERTY ENVIRONMENT COND_WAIT=$<TARGET_FILE:cond-wait>)
set_property(TEST measurement/cstate-latencies APPEND PROPERTY ENVIRONMENT WHILE_TRUE=$<TARGET_FILE:while-true>)

add_test(NAME measurement/cstate-latencies/reboot
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/reboot.sh
)

add_notebook(
    NAME cstate-latencies
    FILE ${CMAKE_CURRENT_SOURCE_DIR}/Plot.ipynb
)