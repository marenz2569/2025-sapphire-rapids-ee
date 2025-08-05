set(add_test_with_output__source_dir ${CMAKE_CURRENT_SOURCE_DIR} CACHE INTERNAL "")

# Function to add test. This function wraps the test with a script that creates a folder for the results.
# This folder is set as the environment variable RESULTS_FOLDER. The script then executes the binary passed
# via the TEST_COMMAND environment variable.
# Argument NAME: The name of the test
# Argument COMMAND: The command that should be executed for the test
function(add_test_with_output)
    set(oneValueArgs NAME COMMAND)
    cmake_parse_arguments(TEST "" "${oneValueArgs}"
                          "" ${ARGN} )

    if(NOT DEFINED TEST_NAME)
        message(FATAL_ERROR "Called add_test_with_output without NAME.")
    endif()
    if(NOT DEFINED TEST_COMMAND)
        message(FATAL_ERROR "Called add_test_with_output without COMMAND.")
    endif()

    add_test(NAME ${TEST_NAME}
        COMMAND ${add_test_with_output__source_dir}/create_folder_and_run_test.sh ${TEST_COMMAND}
    )

    set_property(TEST ${TEST_NAME} APPEND PROPERTY ENVIRONMENT TEST_NAME=${TEST_NAME})
endfunction()

add_subdirectory(avx-frequency-license-bands)
add_subdirectory(avx-frequency-license-bands-validation)
add_subdirectory(shared-frequency-domains)
