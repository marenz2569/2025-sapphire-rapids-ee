
# Measure latency of manual frequency change
add_executable(
    uncore-frequency-manual-switching-latency
    latency_test.c
)

set_target_properties(uncore-frequency-manual-switching-latency PROPERTIES COMPILE_FLAGS "-DMANUAL_FREQUENCY_LATENCY")

# Measure latency of automatic latency change
add_executable(
    uncore-frequency-automatic-switching-latency
    latency_test.c
)

set_target_properties(uncore-frequency-automatic-switching-latency PROPERTIES COMPILE_FLAGS "-DAUTOMATIC_FREQUENCY_LATENCY")