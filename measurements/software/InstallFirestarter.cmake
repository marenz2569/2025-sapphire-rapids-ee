include(ExternalProject)

# Function to build FIRESTARTER with a specified git version
# Argument BRANCH: The git branch that should be build (without the "origin/" perfix)
# Argument REV: The git rev that should be build
function(build_firestarter)
    set(oneValueArgs BRANCH REV)
    cmake_parse_arguments(FIRESTARTER "" "${oneValueArgs}"
                          "" ${ARGN} )

    if(NOT DEFINED FIRESTARTER_BRANCH AND NOT DEFINED FIRESTARTER_REV)
        message(FATAL_ERROR "Called build_firestarter without a REV or BRANCH.")
    endif()
	if(DEFINED FIRESTARTER_BRANCH AND DEFINED FIRESTARTER_REV)
        message(FATAL_ERROR "Called build_firestarter with both a REV or BRANCH.")
    endif()

	if (DEFINED FIRESTARTER_BRANCH)
		SET(FIRESTARTER_TAG_ORIGIN "origin/${FIRESTARTER_BRANCH}")
		SET(FIRESTARTER_TAG        "${FIRESTARTER_BRANCH}")
	endif()
	if (DEFINED FIRESTARTER_REV)
		SET(FIRESTARTER_TAG_ORIGIN "${FIRESTARTER_REV}")
		SET(FIRESTARTER_TAG        "${FIRESTARTER_REV}")
	endif()

	ExternalProject_Add(
		FIRESTARTER-${FIRESTARTER_TAG}
		GIT_REPOSITORY    "https://github.com/tud-zih-energy/FIRESTARTER.git"
		GIT_TAG           "${FIRESTARTER_TAG_ORIGIN}"
		GIT_SHALLOW       OFF
		GIT_PROGRESS      ON
		GIT_REMOTE_UPDATE_STRATEGY CHECKOUT
		SOURCE_DIR        "${CMAKE_CURRENT_BINARY_DIR}/FIRESTARTER-${FIRESTARTER_TAG}-source"
		BINARY_DIR        "${CMAKE_CURRENT_BINARY_DIR}/FIRESTARTER-${FIRESTARTER_TAG}-build"
		INSTALL_DIR       "${CMAKE_CURRENT_BINARY_DIR}/FIRESTARTER-${FIRESTARTER_TAG}-install"
		CONFIGURE_COMMAND cmake -G Ninja <SOURCE_DIR>
		BUILD_COMMAND     ninja
		INSTALL_COMMAND   cp <BINARY_DIR>/src/FIRESTARTER <INSTALL_DIR>/FIRESTARTER
		TEST_COMMAND      ""
	)
endfunction()

build_firestarter(BRANCH marenz.perf_set_cpu)

# Master as of 2025-08-25-1626
build_firestarter(REV 348ab350e264e2735da30c561b4636cb3d029d13)