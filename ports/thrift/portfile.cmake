include(vcpkg_common_functions)

# We currently insist on static only because:
# - Thrift doesn't yet support building as a DLL on Windows,
# - x64-linux only builds static anyway.
# From https://github.com/apache/thrift/blob/master/CHANGES.md
# it looks like it will be supported in v0.13.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/thrift
    REF 286eee16b147a302ddc7b10740c5e5401ebbec17
    SHA512 83aff3a51281ec43228e66b33d15b344710030ee59c1373c6cf33efae9d26db1896ae3518a23b641a7897724d496c38b5217bfc7c41ff538648ec4c571b924f5
    HEAD_REF master
    PATCHES
      "correct-paths.patch"
)

# note we specify values for WITH_STATIC_LIB and WITH_SHARED_LIB because even though
# they're marked as deprecated, Thrift incorrectly hard-codes a value for BUILD_SHARED_LIBS.
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    NO_CHARSET_FLAG
    OPTIONS
        -DWITH_SHARED_LIB=off
        -DWITH_STATIC_LIB=on
        -DWITH_STDTHREADS=ON
        -DBUILD_TESTING=off
        -DBUILD_JAVA=off
        -DBUILD_C_GLIB=off
        -DBUILD_PYTHON=off
        -DBUILD_CPP=on
        -DBUILD_HASKELL=off
        -DBUILD_TUTORIALS=off
        -DFLEX_EXECUTABLE=${FLEX}
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt5=TRUE
        -DBISON_EXECUTABLE=${BISON}
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/thrift RENAME copyright)

# Move CMake config files to the right place
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/thrift)

file(GLOB COMPILER "${CURRENT_PACKAGES_DIR}/bin/thrift" "${CURRENT_PACKAGES_DIR}/bin/thrift.exe")
if(COMPILER)
    file(COPY ${COMPILER} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/thrift)
    file(REMOVE ${COMPILER})
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/thrift)
endif()

file(GLOB COMPILERD "${CURRENT_PACKAGES_DIR}/debug/bin/thrift" "${CURRENT_PACKAGES_DIR}/debug/bin/thrift.exe")
if(COMPILERD)
    file(REMOVE ${COMPILERD})
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if ("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()

vcpkg_copy_pdbs()
