find_package(OpenMP)

add_executable(
    while-true
    while_true.c
)

add_executable(
    while-true-openmp
    while_true.c
)

target_link_libraries(while-true-openmp PUBLIC OpenMP::OpenMP_C)