add_executable (erl_test
  erl_test.c
  utils.c
  spawn.c
  dispatchers.c
  sampling.c
  io.c)

target_include_directories(erl_test PRIVATE
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
  $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>)

set_property(TARGET erl_test PROPERTY C_STANDARD 11)
target_compile_definitions(erl_test PRIVATE _REENTRANT)
target_compile_options(erl_test PRIVATE -fsanitize=address)

target_link_libraries(erl_test
PRIVATE ei rt nsl pthread asan m)
