# sudo -E is required to have sudo working inside the nix chroot
add_measurement(
    NAME metricq-power-distribution
    COMMAND nix run ${CMAKE_CURRENT_SOURCE_DIR}\# -- ${CMAKE_CURRENT_SOURCE_DIR}/run.py
)
