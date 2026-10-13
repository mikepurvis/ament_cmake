# Copyright 2014 Open Source Robotics Foundation, Inc.
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

#
# Export include directories to downstream packages.
#
# Relative paths will be exported before absolute paths.
# Non existing absolute paths will result in warning.
#
# :param ARGN: a list of include directories where each value might
#   be either an absolute path or path relative to the
#   CMAKE_INSTALL_PREFIX.
# :type ARGN: list of strings
#
# @public
#
macro(ament_export_include_directories)
  if(_${PROJECT_NAME}_AMENT_PACKAGE)
    message(FATAL_ERROR "ament_export_include_directories() must be called "
      "before ament_package()")
  endif()

  if(${ARGC} GREATER 0)
    _ament_cmake_export_include_directories_register_package_hook()
    foreach(_arg ${ARGN})
      if(NOT IS_ABSOLUTE "${_arg}")
        # prefix relative paths with CMAKE_INSTALL_PREFIX
        # while avoiding to embed any absolute path
        ament_package_install_prefix(_prefix)
        set(_arg "${_prefix}/${_arg}")
        list_append_unique(_AMENT_EXPORT_RELATIVE_INCLUDE_DIRECTORIES "${_arg}")
      else()
        # an absolute install destination, such as an absolute
        # CMAKE_INSTALL_INCLUDEDIR, is only created at install time
        _ament_cmake_export_include_directories_is_install_destination(_is_install "${_arg}")
        if(NOT _is_install AND NOT IS_DIRECTORY "${_arg}")
          message(WARNING
            "ament_export_include_directories() package '${PROJECT_NAME}' "
            "exports the include directory '${_arg}' which doesn't exist")
        endif()
        list_append_unique(_AMENT_EXPORT_ABSOLUTE_INCLUDE_DIRECTORIES "${_arg}")
      endif()
    endforeach()
  endif()
endmacro()

# Whether a path is at or below one of the places this package installs to.
function(_ament_cmake_export_include_directories_is_install_destination var path)
  set(_destinations "${CMAKE_INSTALL_PREFIX}" "${AMENT_CMAKE_CONFIG_INSTALL_PREFIX}")
  if(IS_ABSOLUTE "${CMAKE_INSTALL_INCLUDEDIR}")
    list(APPEND _destinations "${CMAKE_INSTALL_INCLUDEDIR}")
  endif()
  foreach(_destination ${_destinations})
    string(REGEX REPLACE "/+$" "" _destination "${_destination}")
    if(_destination)
      string(LENGTH "${_destination}/" _length)
      string(SUBSTRING "${path}/" 0 ${_length} _head)
      if(_head STREQUAL "${_destination}/")
        set(${var} TRUE PARENT_SCOPE)
        return()
      endif()
    endif()
  endforeach()
  set(${var} FALSE PARENT_SCOPE)
endfunction()
