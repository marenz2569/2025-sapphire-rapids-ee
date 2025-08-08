include(ExternalProject)

# Master as of 2025-08-08
SET(FMM_REV cca7e030f813398b07542610f01425172b1bf2fc)

ExternalProject_Add(
	firestarter-metric-metricq-${FMM_REV}
	GIT_REPOSITORY    "https://github.com/marenz2569/firestarter-metric-metricq.git"
	GIT_TAG           "${FMM_REV}"
	GIT_SHALLOW       OFF
	GIT_PROGRESS      ON
	GIT_REMOTE_UPDATE_STRATEGY CHECKOUT
	SOURCE_DIR        "${CMAKE_CURRENT_BINARY_DIR}/firestarter-metric-metricq-${FMM_REV}-source"
	BINARY_DIR        "${CMAKE_CURRENT_BINARY_DIR}/firestarter-metric-metricq-${FMM_REV}-build"
	INSTALL_DIR       "${CMAKE_CURRENT_BINARY_DIR}/firestarter-metric-metricq-${FMM_REV}-install"
	CONFIGURE_COMMAND cmake -G Ninja <SOURCE_DIR>
	BUILD_COMMAND     ninja
	INSTALL_COMMAND   cp <BINARY_DIR>/metric-metricq-dumper <INSTALL_DIR> && cp <BINARY_DIR>/libmetric-metricq.so <INSTALL_DIR>
	TEST_COMMAND      ""
)