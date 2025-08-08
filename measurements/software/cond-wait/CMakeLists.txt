find_package(Threads REQUIRED)

add_executable(
    cond-wait
    cond_wait.c
)

target_link_libraries(cond-wait PUBLIC Threads::Threads)