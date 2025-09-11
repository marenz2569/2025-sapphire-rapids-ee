add_measurement(
    NAME robsize
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

ExternalProject_Get_Property(robsize-0d88b24ad82d5d703fbda5c4c8d33ef317eef760 INSTALL_DIR)
set_property(TEST measurement/robsize APPEND PROPERTY ENVIRONMENT ROBSIZE=${INSTALL_DIR}/robsize)

add_notebook(
    NAME robsize
    FILE ${CMAKE_CURRENT_SOURCE_DIR}/Plot.ipynb
)