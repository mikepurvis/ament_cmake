# Copyright 2026 Open Source Robotics Foundation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Run with -DFIXTURE_DIR=<this directory> -DWORK_DIR=<scratch directory>.
# ament_cmake's packages are found through the CMAKE_PREFIX_PATH environment
# variable, as in any workspace.

function(run)
  execute_process(COMMAND ${ARGN}
    RESULT_VARIABLE _result OUTPUT_VARIABLE _output ERROR_VARIABLE _output)
  if(_result)
    string(REPLACE ";" " " _command "${ARGN}")
    message(FATAL_ERROR "Failed: ${_command}\n${_output}")
  endif()
endfunction()

function(build_and_install name)
  run("${CMAKE_COMMAND}" -S "${FIXTURE_DIR}/foo" -B "${WORK_DIR}/${name}/build"
    -DBUILD_TESTING=OFF ${ARGN})
  run("${CMAKE_COMMAND}" --build "${WORK_DIR}/${name}/build")
  run("${CMAKE_COMMAND}" --install "${WORK_DIR}/${name}/build")
endfunction()

function(consume name prefix libdir includedir)
  run("${CMAKE_COMMAND}" -S "${FIXTURE_DIR}/consumer" -B "${WORK_DIR}/${name}/consumer"
    "-DCMAKE_PREFIX_PATH=${prefix}"
    "-DEXPECT_LIBDIR=${libdir}"
    "-DEXPECT_INCLUDEDIR=${includedir}")
  run("${CMAKE_COMMAND}" --build "${WORK_DIR}/${name}/consumer")
endfunction()

file(REMOVE_RECURSE "${WORK_DIR}")

# Split: libraries under one prefix, headers and CMake files under another.
set(out "${WORK_DIR}/split/out")
set(dev "${WORK_DIR}/split/dev")
build_and_install(split
  "-DCMAKE_INSTALL_PREFIX=${out}"
  "-DCMAKE_INSTALL_LIBDIR=${out}/lib"
  "-DCMAKE_INSTALL_INCLUDEDIR=${dev}/include"
  "-DAMENT_CMAKE_CONFIG_INSTALL_PREFIX=${dev}")
if(NOT EXISTS "${dev}/share/foo/cmake/fooConfig.cmake")
  message(FATAL_ERROR "fooConfig.cmake wasn't installed under ${dev}")
endif()
foreach(_misplaced share/foo/cmake include)
  if(EXISTS "${out}/${_misplaced}")
    message(FATAL_ERROR "${_misplaced} was installed under ${out}, not ${dev}")
  endif()
endforeach()
consume(split "${dev}" "${out}/lib" "${dev}/include")

# Default: one relocatable prefix, still found after it moves.
build_and_install(default "-DCMAKE_INSTALL_PREFIX=${WORK_DIR}/default/install")
file(RENAME "${WORK_DIR}/default/install" "${WORK_DIR}/default/moved")
consume(default "${WORK_DIR}/default/moved"
  "${WORK_DIR}/default/moved" "${WORK_DIR}/default/moved/include")
