add_measurement(
    NAME ftalat
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

# 1 day
set_tests_properties(measurement/ftalat PROPERTIES TIMEOUT 86400)

# Master as of May 28 18:18:31 2025
build_ftalat(
    REV 345d02344cbd878c64c0c280f2853d5c107cd7b6
    ID "scaling_setspeed"
    MORE_FLAGS "-DNB_WAIT_RANDOM -DNB_WAIT_US=20000 -DNB_REPORT_TIMES=4000 -DFREQ_SETTER_FILE=\\\"scaling_setspeed\\\""
)

build_ftalat(
    REV 345d02344cbd878c64c0c280f2853d5c107cd7b6
    ID "scaling_max_freq"
    MORE_FLAGS "-DNB_WAIT_RANDOM -DNB_WAIT_US=20000 -DNB_REPORT_TIMES=4000 -DFREQ_SETTER_FILE=\\\"scaling_max_freq\\\""
)

ExternalProject_Get_Property(ftalat-345d02344cbd878c64c0c280f2853d5c107cd7b6-scaling_setspeed INSTALL_DIR)
set_property(TEST measurement/ftalat APPEND PROPERTY ENVIRONMENT FTALAT_SCALING_SETSPEED=${INSTALL_DIR}/ftalat)

ExternalProject_Get_Property(ftalat-345d02344cbd878c64c0c280f2853d5c107cd7b6-scaling_max_freq INSTALL_DIR)
set_property(TEST measurement/ftalat APPEND PROPERTY ENVIRONMENT FTALAT_SCALING_MAX_FREQ=${INSTALL_DIR}/ftalat)

add_notebook(
    NAME ftalat
    FILE ${CMAKE_CURRENT_SOURCE_DIR}/hati_analyze.ipynb
)