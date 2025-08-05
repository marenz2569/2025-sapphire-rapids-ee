include(ExternalProject)

ExternalProject_Add(
	isst-v1.21
	URL https://github.com/spandruvada/intel-speed-select-utility-src-packages/raw/refs/heads/master/intel-speed-select-v1.21.tar.gz

	DEPENDS libnl-3-dev libnl-genl-3-dev libnl-3 libnl-genl-3

	SOURCE_DIR        "${CMAKE_CURRENT_BINARY_DIR}/isst-v1.21-src"
    INSTALL_DIR       "${CMAKE_CURRENT_BINARY_DIR}/isst-v1.21-install"
	BUILD_IN_SOURCE 1
	CONFIGURE_COMMAND ""
	BUILD_COMMAND     patch -p1 < ${CMAKE_CURRENT_SOURCE_DIR}/IntelSpeedSelectSapphireRapids.patch && gcc hfi-events.c isst-config.c isst-core-mbox.c isst-core-tpmi.c isst-core.c isst-daemon.c isst-display.c -D_GNU_SOURCE -Iinclude -I${CMAKE_CURRENT_BINARY_DIR}/libnl3-src/usr/include/libnl3 -L${CMAKE_CURRENT_BINARY_DIR}/libnl3-src/lib/x86_64-linux-gnu -lnl-genl-3 -lnl-3 -o intel-speed-select
	INSTALL_COMMAND   mkdir -p <INSTALL_DIR> && cp <SOURCE_DIR>/intel-speed-select <INSTALL_DIR>/intel-speed-select
	TEST_COMMAND      ""
	DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)