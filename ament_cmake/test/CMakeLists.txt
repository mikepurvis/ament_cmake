# Installs a package with its CMake files and its libraries under different
# prefixes, as packagers who split development files from runtime ones do,
# and checks that a consumer finds everything through the CMake files alone.
# Also checks that a default install still works after being moved.
ament_add_test(split_install
  COMMAND "${CMAKE_COMMAND}"
    "-DFIXTURE_DIR=${CMAKE_CURRENT_SOURCE_DIR}/split_install"
    "-DWORK_DIR=${CMAKE_CURRENT_BINARY_DIR}/split_install"
    -P "${CMAKE_CURRENT_SOURCE_DIR}/split_install/run.cmake"
  GENERATE_RESULT_FOR_RETURN_CODE_ZERO
  TIMEOUT 300
)
