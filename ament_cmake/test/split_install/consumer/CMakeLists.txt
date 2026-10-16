cmake_minimum_required(VERSION 3.12)
project(consumer NONE)

# Fails configuration unless foo's libraries resolve under
# EXPECTED_LIB_PREFIX and its headers under EXPECTED_INCLUDE_DIR.
find_package(foo REQUIRED)

function(expect_under what path prefix)
  string(FIND "${path}" "${prefix}" position)
  if(NOT position EQUAL 0 OR NOT EXISTS "${path}")
    message(FATAL_ERROR "${what} is '${path}', expected an existing path under '${prefix}'")
  endif()
endfunction()

expect_under(foo_LIBRARIES "${foo_LIBRARIES}" "${EXPECTED_LIB_PREFIX}")
get_filename_component(include_dir "${foo_INCLUDE_DIRS}" REALPATH)
get_filename_component(expected_include_dir "${EXPECTED_INCLUDE_DIR}" REALPATH)
if(NOT include_dir STREQUAL expected_include_dir)
  message(FATAL_ERROR "foo_INCLUDE_DIRS is '${foo_INCLUDE_DIRS}', expected '${EXPECTED_INCLUDE_DIR}'")
endif()

get_target_property(location foo::foo IMPORTED_LOCATION_NOCONFIG)
if(NOT location)
  get_target_property(location foo::foo IMPORTED_LOCATION_RELEASE)
endif()
expect_under("foo::foo location" "${location}" "${EXPECTED_LIB_PREFIX}")
