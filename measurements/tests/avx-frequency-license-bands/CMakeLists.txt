add_test_with_output(
    NAME avx-frequency-license-bands
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

ExternalProject_Get_Property(isst-v1.22 INSTALL_DIR)
set_property(TEST avx-frequency-license-bands APPEND PROPERTY ENVIRONMENT ISST=${INSTALL_DIR}/intel-speed-select)