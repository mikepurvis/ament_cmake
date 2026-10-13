cmake_minimum_required(VERSION 3.12)
project(foo C)

find_package(ament_cmake_core REQUIRED)
find_package(ament_cmake_export_include_directories REQUIRED)
find_package(ament_cmake_export_libraries REQUIRED)
find_package(ament_cmake_export_targets REQUIRED)
include(GNUInstallDirs)

add_library(foo SHARED src/foo.c)
target_include_directories(foo PUBLIC
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
  "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/foo>")

install(TARGETS foo EXPORT fooTargets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/foo)

# A CMake module shipped next to the package config.
install(DIRECTORY cmake/ DESTINATION ${AMENT_CMAKE_CONFIG_INSTALL_DIR})

ament_export_include_directories("${CMAKE_INSTALL_INCLUDEDIR}/foo")
ament_export_libraries(foo)
ament_export_targets(fooTargets)
ament_package(CONFIG_EXTRAS "foo-extras.cmake")
