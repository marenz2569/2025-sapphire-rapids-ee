include(ExternalProject)

ExternalProject_Add(
	hwloc-v1.12.1
	DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/hwloc-v1.12.1/download
	SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/hwloc-v1.12.1/sources
	INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/hwloc-v1.12.1/install
	URL https://download.open-mpi.org/release/hwloc/v2.12/hwloc-2.12.1.tar.gz
	URL_HASH SHA1=5996c38d642378093a5c88ac4bd2b9824e6f965e
	CONFIGURE_COMMAND autoreconf -f -i && <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --disable-cuda --disable-rsmi
	BUILD_IN_SOURCE 1
	BUILD_COMMAND make -j
	INSTALL_COMMAND make install
	)