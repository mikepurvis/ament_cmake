add_test(
  NAME split_install
  COMMAND "${CMAKE_COMMAND}"
    "-DFIXTURE_DIR=${CMAKE_CURRENT_SOURCE_DIR}/split_install"
    "-DWORK_DIR=${CMAKE_CURRENT_BINARY_DIR}/split_install"
    -P "${CMAKE_CURRENT_SOURCE_DIR}/test_split_install.cmake")
