add_measurement(
    NAME avx-frequency-uncore-anomaly
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

# 56 * 8 * 60 (measurement duration) * 2 (to be safe)

# 20s (measurement duration) * 4 measurement * 100 repetition * 2 (to be safe)
set_tests_properties(measurement/avx-frequency-uncore-anomaly PROPERTIES TIMEOUT 16000)

ExternalProject_Get_Property(FIRESTARTER-marenz.perf_set_cpu INSTALL_DIR)
set_property(TEST measurement/avx-frequency-uncore-anomaly APPEND PROPERTY ENVIRONMENT FIRESTARTER=${INSTALL_DIR}/FIRESTARTER)

ExternalProject_Get_Property(intel-uncore-freq-dumper-a150b9a6af1decadf43bfa82a02f0882301210df INSTALL_DIR)
set_property(TEST measurement/avx-frequency-uncore-anomaly APPEND PROPERTY ENVIRONMENT IUFD=${INSTALL_DIR}/intel-uncore-freq-dumper)

add_test(NAME measurement/avx-frequency-uncore-anomaly/reboot
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/reboot.sh
)

add_notebook(
    NAME avx-frequency-uncore-anomaly
    FILE ${CMAKE_CURRENT_SOURCE_DIR}/Plot.ipynb
)