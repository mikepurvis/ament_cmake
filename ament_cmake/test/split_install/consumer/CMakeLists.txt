cmake_minimum_required(VERSION 3.12)
project(consumer C)

# EXPECT_LIBDIR and EXPECT_INCLUDEDIR say where foo's library and headers
# were installed.
find_package(foo REQUIRED)

function(expect_under what path dir)
  string(LENGTH "${dir}/" _length)
  string(SUBSTRING "${path}" 0 ${_length} _head)
  if(NOT _head STREQUAL "${dir}/" OR NOT EXISTS "${path}")
    message(FATAL_ERROR "${what} is '${path}', expected an existing path under '${dir}'")
  endif()
endfunction()

if(NOT foo_HELPER_LOADED)
  message(FATAL_ERROR "foo's CMake helper module wasn't found next to its config")
endif()

list(GET foo_LIBRARIES 0 _library)
expect_under(foo_LIBRARIES "${_library}" "${EXPECT_LIBDIR}")
list(GET foo_INCLUDE_DIRS 0 _include)
expect_under(foo_INCLUDE_DIRS "${_include}" "${EXPECT_INCLUDEDIR}")

get_target_property(_configs foo::foo IMPORTED_CONFIGURATIONS)
list(GET _configs 0 _config)
get_target_property(_location foo::foo IMPORTED_LOCATION_${_config})
expect_under("foo::foo location" "${_location}" "${EXPECT_LIBDIR}")
get_target_property(_target_include foo::foo INTERFACE_INCLUDE_DIRECTORIES)
expect_under("foo::foo includes" "${_target_include}" "${EXPECT_INCLUDEDIR}")

# And it links.
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/main.c"
  "#include \"foo/foo.h\"\nint main(void) { return foo() == 42 ? 0 : 1; }\n")
add_executable(consumer "${CMAKE_CURRENT_BINARY_DIR}/main.c")
target_link_libraries(consumer foo::foo)
