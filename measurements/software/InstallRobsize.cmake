include(ExternalProject)

# Function to build ROBSIZE with a specified git version
# Argument BRANCH: The git branch that should be build (without the "origin/" perfix)
# Argument REV: The git rev that should be build
function(build_robsize)
    set(oneValueArgs BRANCH REV)
    cmake_parse_arguments(ROBSIZE "" "${oneValueArgs}"
                          "" ${ARGN} )

    if(NOT DEFINED ROBSIZE_BRANCH AND NOT DEFINED ROBSIZE_REV)
        message(FATAL_ERROR "Called build_robsize without a REV or BRANCH.")
    endif()
	if(DEFINED ROBSIZE_BRANCH AND DEFINED ROBSIZE_REV)
        message(FATAL_ERROR "Called build_robsize with both a REV or BRANCH.")
    endif()

	if (DEFINED ROBSIZE_BRANCH)
		SET(ROBSIZE_TAG_ORIGIN "origin/${ROBSIZE_BRANCH}")
		SET(ROBSIZE_TAG        "${ROBSIZE_BRANCH}")
	endif()
	if (DEFINED ROBSIZE_REV)
		SET(ROBSIZE_TAG_ORIGIN "${ROBSIZE_REV}")
		SET(ROBSIZE_TAG        "${ROBSIZE_REV}")
	endif()

	ExternalProject_Add(
		robsize-${ROBSIZE_TAG}
		GIT_REPOSITORY    "https://github.com/marenz2569/robsize.git"
		GIT_TAG           "${ROBSIZE_TAG_ORIGIN}"
		GIT_SHALLOW       OFF
		GIT_PROGRESS      ON
		GIT_REMOTE_UPDATE_STRATEGY CHECKOUT
		SOURCE_DIR        "${CMAKE_CURRENT_BINARY_DIR}/robsize-${ROBSIZE_TAG}-source"
		BINARY_DIR        "${CMAKE_CURRENT_BINARY_DIR}/robsize-${ROBSIZE_TAG}-build"
		INSTALL_DIR       "${CMAKE_CURRENT_BINARY_DIR}/robsize-${ROBSIZE_TAG}-install"
		CONFIGURE_COMMAND cmake -G Ninja <SOURCE_DIR>
		BUILD_COMMAND     ninja
		INSTALL_COMMAND   cp <BINARY_DIR>/src/robsize <INSTALL_DIR>/robsize
		TEST_COMMAND      ""
	)
endfunction()

# Master as of 2025-09-11
build_robsize(REV 0d88b24ad82d5d703fbda5c4c8d33ef317eef760)