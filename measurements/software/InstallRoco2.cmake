include(ExternalProject)

# Master as of 2025-08-25-1630
SET(ROCO2_REV marenz.hati-config)

ExternalProject_Add(
	roco2-${ROCO2_REV}
	GIT_REPOSITORY    "https://github.com/marenz2569/roco2.git"
	GIT_TAG           "origin/${ROCO2_REV}"
	GIT_SHALLOW       OFF
	GIT_PROGRESS      ON
	GIT_REMOTE_UPDATE_STRATEGY CHECKOUT
	SOURCE_DIR        "${CMAKE_CURRENT_BINARY_DIR}/roco2-${ROCO2_REV}-source"
	BINARY_DIR        "${CMAKE_CURRENT_BINARY_DIR}/roco2-${ROCO2_REV}-build"
	INSTALL_DIR       "${CMAKE_CURRENT_BINARY_DIR}/roco2-${ROCO2_REV}-install"
	CONFIGURE_COMMAND cmake -G Ninja <SOURCE_DIR>
	BUILD_COMMAND     ninja roco2_hati
	INSTALL_COMMAND   cp <BINARY_DIR>/src/configurations/hati/roco2_hati <INSTALL_DIR>/roco2_hati
	TEST_COMMAND      ""
)