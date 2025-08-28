add_measurement(
    NAME avx-frequency-license-bands
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/run.sh
)

add_notebook(
    NAME avx-frequency-license-bands
    FILE ${CMAKE_CURRENT_SOURCE_DIR}/Plot.ipynb
)