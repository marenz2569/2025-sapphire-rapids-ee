# sudo -E is required to have sudo working inside the nix chroot
add_measurement(
    NAME core-to-core-latency
    COMMAND bash -c "sudo -E $(which nix) run ${CMAKE_CURRENT_SOURCE_DIR}\# -- ${CMAKE_CURRENT_SOURCE_DIR}/core_to_core_latency.py"
)

set_property(TEST measurement/core-to-core-latency APPEND PROPERTY ENVIRONMENT ATOMIC_LATENCIES=$<TARGET_FILE:atomic-latencies>)

add_notebook(
    NAME core-to-core-latency
    FILE ${CMAKE_CURRENT_SOURCE_DIR}/PlotAll.ipynb
)