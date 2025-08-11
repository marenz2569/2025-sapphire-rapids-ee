include(ExternalProject)

ExternalProject_Add(
	stream

	URL https://www.cs.virginia.edu/stream/FTP/Code/stream.c
	DOWNLOAD_NO_EXTRACT ON

    INSTALL_DIR       "${CMAKE_CURRENT_BINARY_DIR}/stream-install"
	BUILD_IN_SOURCE 1
	CONFIGURE_COMMAND ""
	BUILD_COMMAND     gcc <SOURCE_DIR>.c -o stream
	INSTALL_COMMAND   mkdir -p <INSTALL_DIR> && cp <SOURCE_DIR>/stream <INSTALL_DIR>/stream
	TEST_COMMAND      ""
)