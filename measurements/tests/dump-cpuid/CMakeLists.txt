add_measurement(
    NAME dump-cpuid
    COMMAND taskset -c 0 nix run ${CMAKE_CURRENT_SOURCE_DIR}#cpuid -- -1
)