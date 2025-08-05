add_test_with_output(
    NAME avx-frequency-license-bands-validation
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

# 56 * 8 * 250 (10s measurement) * 2 (to be safe)
set_tests_properties(avx-frequency-license-bands-validation PROPERTIES TIMEOUT 8960)

ExternalProject_Get_Property(isst-v1.22 INSTALL_DIR)
set_property(TEST avx-frequency-license-bands-validation APPEND PROPERTY ENVIRONMENT ISST=${INSTALL_DIR}/intel-speed-select)

ExternalProject_Get_Property(FIRESTARTER-marenz.perf_set_cpu INSTALL_DIR)
set_property(TEST avx-frequency-license-bands-validation APPEND PROPERTY ENVIRONMENT FIRESTARTER=${INSTALL_DIR}/FIRESTARTER)