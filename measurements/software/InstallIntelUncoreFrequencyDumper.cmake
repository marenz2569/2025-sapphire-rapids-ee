include(ExternalProject)

# Master as of 2025-08-25-1630
SET(IUFD_REV a150b9a6af1decadf43bfa82a02f0882301210df)

ExternalProject_Add(
	intel-uncore-freq-dumper-${IUFD_REV}
	GIT_REPOSITORY    "https://github.com/marenz2569/intel-uncore-freq-dumper.git"
	GIT_TAG           "${IUFD_REV}"
	GIT_SHALLOW       OFF
	GIT_PROGRESS      ON
	GIT_REMOTE_UPDATE_STRATEGY CHECKOUT
	SOURCE_DIR        "${CMAKE_CURRENT_BINARY_DIR}/intel-uncore-freq-dumper-${IUFD_REV}-source"
	BINARY_DIR        "${CMAKE_CURRENT_BINARY_DIR}/intel-uncore-freq-dumper-${IUFD_REV}-build"
	INSTALL_DIR       "${CMAKE_CURRENT_BINARY_DIR}/intel-uncore-freq-dumper-${IUFD_REV}-install"
	CONFIGURE_COMMAND cmake -G Ninja <SOURCE_DIR>
	BUILD_COMMAND     ninja
	INSTALL_COMMAND   cp <BINARY_DIR>/src/intel-uncore-freq-dumper <INSTALL_DIR>/intel-uncore-freq-dumper
	TEST_COMMAND      ""
)