add_measurement(
    NAME uncore-core-frequency-relationship
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

set_property(TEST measurement/uncore-core-frequency-relationship APPEND PROPERTY ENVIRONMENT WHILE_TRUE=$<TARGET_FILE:while-true-openmp>)

ExternalProject_Get_Property(intel-uncore-freq-dumper-a150b9a6af1decadf43bfa82a02f0882301210df INSTALL_DIR)
set_property(TEST measurement/uncore-core-frequency-relationship APPEND PROPERTY ENVIRONMENT IUFD=${INSTALL_DIR}/intel-uncore-freq-dumper)