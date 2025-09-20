add_measurement(
    NAME avx-frequency-license-bands-without-isst
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

# 60s (measurement duration) * 56 * 4 * 4 * 2 * 4 * 2 (to be safe)
set_tests_properties(measurement/avx-frequency-license-bands-without-isst PROPERTIES TIMEOUT 860160)

ExternalProject_Get_Property(FIRESTARTER-marenz.perf_set_cpu INSTALL_DIR)
set_property(TEST measurement/avx-frequency-license-bands-without-isst APPEND PROPERTY ENVIRONMENT FIRESTARTER=${INSTALL_DIR}/FIRESTARTER)

ExternalProject_Get_Property(intel-uncore-freq-dumper-a150b9a6af1decadf43bfa82a02f0882301210df INSTALL_DIR)
set_property(TEST measurement/avx-frequency-license-bands-without-isst APPEND PROPERTY ENVIRONMENT IUFD=${INSTALL_DIR}/intel-uncore-freq-dumper)

# Prepend the elab executable to the path
set_property(TEST measurement/avx-frequency-license-bands-without-isst APPEND PROPERTY ENVIRONMENT_MODIFICATION "PATH=path_list_prepend:${PROJECT_SOURCE_DIR}/software/elab")

add_notebook(
    NAME avx-frequency-license-bands-without-isst
    FILE ${CMAKE_CURRENT_SOURCE_DIR}/Plot.ipynb
)