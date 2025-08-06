include(ExternalProject)

# Function to build ftalat with a specified git version
# Argument REV: The git rev that should be build
# Argument ID: A unique id for this build
# Argument MORE_FLAGS: The build arguments passed to the Makefile
function(build_ftalat)
    set(oneValueArgs REV ID MORE_FLAGS)
    cmake_parse_arguments(FTALAT "" "${oneValueArgs}"
                          "" ${ARGN} )

    if(NOT DEFINED FTALAT_REV)
        message(FATAL_ERROR "Called build_ftalat without a REV.")
    endif()
    if(NOT DEFINED FTALAT_ID)
        message(FATAL_ERROR "Called build_ftalat without a ID.")
    endif()
	if(NOT DEFINED FTALAT_MORE_FLAGS)
        message(FATAL_ERROR "Called build_ftalat without MORE_FLAGS.")
    endif()

	ExternalProject_Add(
		ftalat-${FTALAT_REV}-${FTALAT_ID}
		GIT_REPOSITORY    "https://github.com/marenz2569/ftalat.git"
		GIT_TAG           "${FTALAT_REV}"
		GIT_SHALLOW       OFF
		GIT_PROGRESS      ON
		GIT_REMOTE_UPDATE_STRATEGY CHECKOUT
		SOURCE_DIR        "${CMAKE_CURRENT_BINARY_DIR}/ftalat-${FTALAT_REV}-${FTALAT_ID}-source"
		INSTALL_DIR       "${CMAKE_CURRENT_BINARY_DIR}/ftalat-${FTALAT_REV}-${FTALAT_ID}-install"
		BUILD_IN_SOURCE   ON
		CONFIGURE_COMMAND ""
		BUILD_COMMAND     export MORE_FLAGS=${FTALAT_MORE_FLAGS} && make
		INSTALL_COMMAND   cp <SOURCE_DIR>/ftalat <INSTALL_DIR>/ftalat
		TEST_COMMAND      ""
	)
endfunction()