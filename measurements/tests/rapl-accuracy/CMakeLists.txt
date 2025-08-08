add_test_with_output(
    NAME rapl-accuracy
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

# 4 (each quadrant) * 3 (frequencies) * 3 (cstates) * 9 (nb. of experiments) * 60 (experiment durations) * 2 (to be safe)
set_tests_properties(measurement/rapl-accuracy PROPERTIES TIMEOUT 38880)

ExternalProject_Get_Property(roco2-marenz.hati-config INSTALL_DIR)
set_property(TEST measurement/rapl-accuracy APPEND PROPERTY ENVIRONMENT ROCO2=${INSTALL_DIR}/roco2_hati)
