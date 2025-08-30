add_subdirectory(atomic-latencies)
add_subdirectory(cond-wait)
add_subdirectory(rapl-update-intervals)
add_subdirectory(uncore-frequency-switching-latency)
add_subdirectory(while-true)

# InstallIntelUncoreFrequencyDumper depends on Libnl3
include(InstallLibnl3.cmake)

include(InstallFirestarter.cmake)
include(InstallFirestarterMetricMetricq.cmake)
include(InstallFtalat.cmake)
include(InstallHwloc.cmake)
include(InstallIntelSpeedSelect.cmake)
include(InstallIntelUncoreFrequencyDumper.cmake)
include(InstallRoco2.cmake)
include(InstallStream.cmake)