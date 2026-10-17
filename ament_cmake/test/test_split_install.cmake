# Installs a small package two ways and checks that a consumer finds it:
#
# - split: CMake config files under one prefix and libraries under another,
#   as a packager keeping development and runtime files apart would, using
#   AMENT_CMAKE_CONFIG_INSTALL_PREFIX and absolute GNUInstallDirs variables;
# - default: an ordinary install, moved after installing, to check it is
#   still relocatable.
#
# Expects FIXTURE_DIR and WORK_DIR, and ament_cmake on CMAKE_PREFIX_PATH.

function(run)
  execute_process(COMMAND ${ARGN}
    RESULT_VARIABLE result OUTPUT_VARIABLE output ERROR_VARIABLE output)
  if(NOT result EQUAL 0)
    message(FATAL_ERROR "Command failed (${result}): ${ARGN}\n${output}")
  endif()
  set(output "${output}" PARENT_SCOPE)
endfunction()

function(install_foo build_dir)
  run("${CMAKE_COMMAND}" -S "${FIXTURE_DIR}/foo" -B "${build_dir}" ${ARGN})
  if(output MATCHES "doesn't exist")
    message(FATAL_ERROR "Configuring foo warned about a missing directory:\n${output}")
  endif()
  run("${CMAKE_COMMAND}" --build "${build_dir}")
  run("${CMAKE_COMMAND}" --install "${build_dir}")
endfunction()

function(consume build_dir prefix_path lib_prefix include_dir datadir)
  run("${CMAKE_COMMAND}" -S "${FIXTURE_DIR}/consumer" -B "${build_dir}"
    "-DCMAKE_PREFIX_PATH=${prefix_path}"
    "-DEXPECTED_LIB_PREFIX=${lib_prefix}"
    "-DEXPECTED_INCLUDE_DIR=${include_dir}"
    "-DEXPECTED_DATADIR=${datadir}")
endfunction()

file(REMOVE_RECURSE "${WORK_DIR}")

# Split install
set(out "${WORK_DIR}/out")
set(dev "${WORK_DIR}/dev")
install_foo("${WORK_DIR}/build-split"
  "-DCMAKE_INSTALL_PREFIX=${out}"
  "-DCMAKE_INSTALL_LIBDIR=${out}/lib"
  "-DCMAKE_INSTALL_INCLUDEDIR=${dev}/include"
  "-DAMENT_CMAKE_CONFIG_INSTALL_PREFIX=${dev}")
if(NOT EXISTS "${dev}/share/foo/cmake/fooConfig.cmake")
  message(FATAL_ERROR "fooConfig.cmake was not installed under ${dev}")
endif()
file(GLOB_RECURSE stray_cmake_files "${out}/*.cmake")
if(stray_cmake_files)
  message(FATAL_ERROR "CMake files were installed under ${out}: ${stray_cmake_files}")
endif()
consume("${WORK_DIR}/consume-split" "${dev}" "${out}/lib/" "${dev}/include"
  "${out}/share/foo")

# Default install, relocated
install_foo("${WORK_DIR}/build-default" "-DCMAKE_INSTALL_PREFIX=${WORK_DIR}/default")
file(RENAME "${WORK_DIR}/default" "${WORK_DIR}/moved")
consume("${WORK_DIR}/consume-moved" "${WORK_DIR}/moved"
  "${WORK_DIR}/moved/" "${WORK_DIR}/moved/include" "${WORK_DIR}/moved/share/foo")
