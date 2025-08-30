
# Measure latency of manual frequency change
add_executable(
    uncore-frequency-manual-switching-latency
    latency_test.c
)


# Set NB_WAIT_ITERATIONS to 10ms.
# We can only set the number of additional cycles,
# so we make sure that we calculate with the highest performing setting for the calcuations from ms to cycles.
# Values from Jupyter Notebook: Lowest performance in cycles is 215.0, Highest performance in cycles is 26.0
# 10ms / (26 cycles / 2GHz) ~= 800000

set_target_properties(uncore-frequency-manual-switching-latency PROPERTIES COMPILE_FLAGS "-DMANUAL_FREQUENCY_LATENCY -DNB_WAIT_RANDOM -DNB_WAIT_ITERATIONS=800000")

# Measure latency of automatic latency change
add_executable(
    uncore-frequency-automatic-switching-latency
    latency_test.c
)

set_target_properties(uncore-frequency-automatic-switching-latency PROPERTIES COMPILE_FLAGS "-DAUTOMATIC_FREQUENCY_LATENCY -DNB_WAIT_RANDOM -DNB_WAIT_ITERATIONS=800000")