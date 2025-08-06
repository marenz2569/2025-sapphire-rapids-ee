add_test_with_output(
    NAME avx-frequency-license-bands-validation
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

# 56 * 8 * 60 (measurement duration) * 2 (to be safe)
set_tests_properties(avx-frequency-license-bands-validation PROPERTIES TIMEOUT 53760)

ExternalProject_Get_Property(FIRESTARTER-marenz.perf_set_cpu INSTALL_DIR)
set_property(TEST avx-frequency-license-bands-validation APPEND PROPERTY ENVIRONMENT FIRESTARTER=${INSTALL_DIR}/FIRESTARTER)
