cmake_minimum_required(VERSION 3.22)
project(FIRESTARTER)

include(cmake/GitSubmoduleUpdate.cmake)
git_submodule_update()

add_subdirectory(software)