include(ExternalProject)

ExternalProject_Add(
	hwloc-v1.12.1
	PREFIX ${PROJECT_SOURCE_DIR}/lib/Hwloc
	DOWNLOAD_DIR ${PROJECT_SOURCE_DIR}/lib/Hwloc/download
	SOURCE_DIR ${PROJECT_SOURCE_DIR}/lib/Hwloc/sources
	INSTALL_DIR ${PROJECT_SOURCE_DIR}/lib/Hwloc/install
	URL https://download.open-mpi.org/release/hwloc/v2.12/hwloc-2.12.1.tar.gz
	URL_HASH SHA1=5996c38d642378093a5c88ac4bd2b9824e6f965e
	CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
	BUILD_IN_SOURCE 1
	BUILD_COMMAND make -j
	INSTALL_COMMAND make install
	)