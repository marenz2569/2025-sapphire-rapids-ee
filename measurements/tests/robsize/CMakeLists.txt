add_measurement(
    NAME robsize
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

ExternalProject_Get_Property(robsize-137578e8d25cd38659d08d49c44b646b5cb53247 INSTALL_DIR)
set_property(TEST measurement/robsize APPEND PROPERTY ENVIRONMENT ROBSIZE=${INSTALL_DIR}/robsize)

add_notebook(
    NAME robsize
    FILE ${CMAKE_CURRENT_SOURCE_DIR}/Plot.ipynb
)