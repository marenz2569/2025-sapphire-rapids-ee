add_measurement(
    NAME metricq-power-distribution
    COMMAND nix run ${CMAKE_CURRENT_SOURCE_DIR}\# -- ${CMAKE_CURRENT_SOURCE_DIR}/metricq_power_distribution.py
)

add_notebook(
    NAME metricq-power-distribution
    FILE ${CMAKE_CURRENT_SOURCE_DIR}/Plot.ipynb
)