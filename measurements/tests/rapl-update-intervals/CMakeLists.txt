add_measurement(
    NAME rapl-update-intervals
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

set_property(TEST measurement/rapl-update-intervals APPEND PROPERTY ENVIRONMENT RAPL_UPDATE_INTERVALS=$<TARGET_FILE:rapl-update-intervals>)

ExternalProject_Get_Property(FIRESTARTER-348ab350e264e2735da30c561b4636cb3d029d13 INSTALL_DIR)
set_property(TEST measurement/rapl-update-intervals APPEND PROPERTY ENVIRONMENT FIRESTARTER=${INSTALL_DIR}/FIRESTARTER)

add_notebook(
    NAME rapl-update-intervals
    FILE ${CMAKE_CURRENT_SOURCE_DIR}/Plot.ipynb
)