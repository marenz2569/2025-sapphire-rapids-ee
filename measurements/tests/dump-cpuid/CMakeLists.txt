add_measurement(
    NAME cpuid
    COMMAND taskset -c 0 nix run ${CMAKE_CURRENT_SOURCE_DIR}#cpuid -- -1
)