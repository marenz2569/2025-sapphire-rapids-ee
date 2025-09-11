add_measurement(
    NAME robsize
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

ExternalProject_Get_Property(robsize-ebd2f95c9e516b2a9a9f3ad76cefd2ac538af0ea INSTALL_DIR)
set_property(TEST measurement/robsize APPEND PROPERTY ENVIRONMENT ROBSIZE=${INSTALL_DIR}/robsize)

add_notebook(
    NAME robsize
    FILE ${CMAKE_CURRENT_SOURCE_DIR}/Plot.ipynb
)