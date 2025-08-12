set(add_measurement__source_dir ${CMAKE_CURRENT_SOURCE_DIR} CACHE INTERNAL "")

# Function to add measurement. This function wraps the measurement with a script that creates a folder for the results.
# This folder is set as the environment variable RESULTS_FOLDER. The script then executes the binary passed
# via the TEST_COMMAND environment variable.
# Argument NAME: The name of the test
# Argument COMMAND: The command that should be executed for the test
function(add_measurement)
    set(oneValueArgs NAME COMMAND)
    cmake_parse_arguments(TEST "" "${oneValueArgs}"
                          "" ${ARGN} )

    if(NOT DEFINED TEST_NAME)
        message(FATAL_ERROR "Called add_test_with_output without NAME.")
    endif()
    if(NOT DEFINED TEST_COMMAND)
        message(FATAL_ERROR "Called add_test_with_output without COMMAND.")
    endif()

    add_test(NAME measurement/${TEST_NAME}
        COMMAND ${add_measurement__source_dir}/test_wrapper.sh ${TEST_COMMAND}
    )

    set_property(TEST measurement/${TEST_NAME} APPEND PROPERTY ENVIRONMENT TEST_NAME=${TEST_NAME})

    # Import ISST as we need to reset it to defaults
    ExternalProject_Get_Property(isst-v1.22 INSTALL_DIR)
    set_property(TEST measurement/${TEST_NAME} APPEND PROPERTY ENVIRONMENT ISST=${INSTALL_DIR}/intel-speed-select)
endfunction()

add_subdirectory(avx-frequency-license-bands)
add_subdirectory(avx-frequency-license-bands-validation)
add_subdirectory(avx-frequency-license-bands-without-isst)
add_subdirectory(avx-frequency-uncore-anomaly)
add_subdirectory(core-layout)
add_subdirectory(cstate-latencies)
add_subdirectory(dump-msr)
add_subdirectory(ftalat)
add_subdirectory(rapl-accuracy)
add_subdirectory(shared-frequency-domains)
add_subdirectory(uncore-core-frequency-relationship)
add_subdirectory(uncore-frequency-switching-latency)

add_test(NAME tooling/reset-cpu-to-performance
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/reset_cpu.sh performance
)
add_test(NAME tooling/reset-cpu-to-powersave
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/reset_cpu.sh powersave
)
