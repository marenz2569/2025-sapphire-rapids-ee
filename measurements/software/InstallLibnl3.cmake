include(ExternalProject)

file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/libnl3-src")

ExternalProject_Add(
	libnl-3-dev
	URL http://de.archive.ubuntu.com/ubuntu/pool/main/libn/libnl3/libnl-3-dev_3.5.0-0.1_amd64.deb

	SOURCE_DIR        "${CMAKE_CURRENT_BINARY_DIR}/libnl-3-dev"
    INSTALL_DIR       "${CMAKE_CURRENT_BINARY_DIR}/libnl3-src"
	BUILD_IN_SOURCE 1
	CONFIGURE_COMMAND ""
	BUILD_COMMAND     ""
	INSTALL_COMMAND   tar xvf ${CMAKE_CURRENT_BINARY_DIR}/libnl-3-dev/data.tar.zst -C ${CMAKE_CURRENT_BINARY_DIR}/libnl3-src
	DOWNLOAD_EXTRACT_TIMESTAMP ON
)

ExternalProject_Add(
	libnl-genl-3-dev
	URL http://de.archive.ubuntu.com/ubuntu/pool/main/libn/libnl3/libnl-genl-3-dev_3.5.0-0.1_amd64.deb
	SOURCE_DIR        "${CMAKE_CURRENT_BINARY_DIR}/libnl-genl-3-dev"
    INSTALL_DIR       "${CMAKE_CURRENT_BINARY_DIR}/libnl3-src"
	BUILD_IN_SOURCE 1
	CONFIGURE_COMMAND ""
	BUILD_COMMAND     ""
	INSTALL_COMMAND   tar xvf ${CMAKE_CURRENT_BINARY_DIR}/libnl-genl-3-dev/data.tar.zst -C ${CMAKE_CURRENT_BINARY_DIR}/libnl3-src
	DOWNLOAD_EXTRACT_TIMESTAMP ON
)

ExternalProject_Add(
	libnl-genl-3
	URL http://de.archive.ubuntu.com/ubuntu/pool/main/libn/libnl3/libnl-genl-3-200_3.5.0-0.1_amd64.deb

	SOURCE_DIR        "${CMAKE_CURRENT_BINARY_DIR}/libnl-genl-3"
    INSTALL_DIR       "${CMAKE_CURRENT_BINARY_DIR}/libnl3-src"
	BUILD_IN_SOURCE 1
	CONFIGURE_COMMAND ""
	BUILD_COMMAND     ""
	INSTALL_COMMAND   tar xvf ${CMAKE_CURRENT_BINARY_DIR}/libnl-genl-3/data.tar.zst -C ${CMAKE_CURRENT_BINARY_DIR}/libnl3-src
	DOWNLOAD_EXTRACT_TIMESTAMP ON
)

ExternalProject_Add(
	libnl-3
	URL http://de.archive.ubuntu.com/ubuntu/pool/main/libn/libnl3/libnl-3-200_3.5.0-0.1_amd64.deb

	SOURCE_DIR        "${CMAKE_CURRENT_BINARY_DIR}/libnl-3"
    INSTALL_DIR       "${CMAKE_CURRENT_BINARY_DIR}/libnl3-src"
	BUILD_IN_SOURCE 1
	CONFIGURE_COMMAND ""
	BUILD_COMMAND     ""
	INSTALL_COMMAND   tar xvf ${CMAKE_CURRENT_BINARY_DIR}/libnl-3/data.tar.zst -C ${CMAKE_CURRENT_BINARY_DIR}/libnl3-src
	DOWNLOAD_EXTRACT_TIMESTAMP ON
)