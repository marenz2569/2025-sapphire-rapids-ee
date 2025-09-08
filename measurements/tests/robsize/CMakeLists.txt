add_measurement(
    NAME robsize
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

ExternalProject_Get_Property(robsize-677bcc5fc6cada3f386835a00400c3c0fab7dbc3 INSTALL_DIR)
set_property(TEST measurement/robsize APPEND PROPERTY ENVIRONMENT ROBSIZE=${INSTALL_DIR}/robsize)