add_measurement(
    NAME avx-frequency-license-bands-validation
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

# 60s (measurement duration) * 56 * 4 * 4 * 2 * 4 * 2 (to be safe)
set_tests_properties(measurement/avx-frequency-license-bands-validation PROPERTIES TIMEOUT 860160)

ExternalProject_Get_Property(FIRESTARTER-marenz.perf_set_cpu INSTALL_DIR)
set_property(TEST measurement/avx-frequency-license-bands-validation APPEND PROPERTY ENVIRONMENT FIRESTARTER=${INSTALL_DIR}/FIRESTARTER)
