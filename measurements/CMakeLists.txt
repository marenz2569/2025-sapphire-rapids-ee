cmake_minimum_required(VERSION 3.22)
project(2025-diploma-thesis)
enable_testing()

include(cmake/GitSubmoduleUpdate.cmake)
git_submodule_update()

add_subdirectory(software)