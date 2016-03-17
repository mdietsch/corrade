# - Find Corrade
#
# Basic usage:
#  find_package(Corrade [REQUIRED])
# This module tries to find Corrade library and then defines:
#  CORRADE_FOUND                    - True if Corrade is found
#  CORRADE_INCLUDE_DIRS             - Corrade include directories
#  CORRADE_INTERCONNECT_LIBRARIES   - Interconnect library and dependent
#   libraries
#  CORRADE_UTILITY_LIBRARIES        - Utility library and dependent
#   libraries
#  CORRADE_PLUGINMANAGER_LIBRARIES  - PluginManager library and dependent
#   libraries
#  CORRADE_TESTSUITE_LIBRARIES      - TestSuite library and dependent
#   libraries
#  CORRADE_RC_EXECUTABLE            - Resource compiler executable
#  CORRADE_LIB_SUFFIX_MODULE        - Path to CorradeLibSuffix.cmake module
# The package is found if either debug or release version of each library is
# found. If both debug and release libraries are found, proper version is
# chosen based on actual build configuration of the project (i.e. Debug build
# is linked to debug libraries, Release build to release libraries).
#
# Corrade conditionally defines CORRADE_IS_DEBUG_BUILD preprocessor variable in
# case build configuration is Debug (not Corrade itself, but build
# configuration of the project using it). Useful e.g. for selecting proper
# plugin directory.
#
# Corrade configures the compiler to use C++11 standard (if it is not already
# configured to do so). Additionally you can use CORRADE_CXX_FLAGS to enable
# additional pedantic set of warnings and enable hidden visibility by default.
#
# Features of found Corrade library are exposed in these variables:
#  CORRADE_GCC47_COMPATIBILITY  - Defined if compiled with compatibility
#   mode for GCC 4.7
#  CORRADE_MSVC2015_COMPATIBILITY - Defined if compiled with compatibility
#   mode for MSVC 2015
#  CORRADE_BUILD_DEPRECATED     - Defined if compiled with deprecated APIs
#   included
#  CORRADE_BUILD_STATIC         - Defined if compiled as static libraries
#  CORRADE_TARGET_UNIX          - Defined if compiled for some Unix flavor
#   (Linux, BSD, OS X)
#  CORRADE_TARGET_APPLE         - Defined if compiled for Apple platforms
#  CORRADE_TARGET_IOS           - Defined if compiled for iOS
#  CORRADE_TARGET_WINDOWS       - Defined if compiled for Windows
#  CORRADE_TARGET_WINDOWS_RT    - Defined if compiled for Windows RT
#  CORRADE_TARGET_NACL          - Defined if compiled for Google Chrome
#   Native Client
#  CORRADE_TARGET_NACL_NEWLIB   - Defined if compiled for Google Chrome
#   Native Client with `newlib` toolchain
#  CORRADE_TARGET_NACL_GLIBC    - Defined if compiled for Google Chrome
#   Native Client with `glibc` toolchain
#  CORRADE_TARGET_EMSCRIPTEN    - Defined if compiled for Emscripten
#  CORRADE_TARGET_ANDROID       - Defined if compiled for Android
#
# Corrade provides these macros and functions:
#
#
# Add unit test using Corrade's TestSuite.
#  corrade_add_test(test_name
#                   sources...
#                   [LIBRARIES libraries...])
# Test name is also executable name. You can also specify libraries to link
# with instead of using target_link_libraries(). CORRADE_TESTSUITE_LIBRARIES
# are linked automatically to each test. Note that the enable_testing()
# function must be called explicitly.
#
#
# Compile data resources into application binary.
#  corrade_add_resource(name resources.conf)
# Depends on corrade-rc, which is part of Corrade utilities. This command
# generates resource data using given configuration file in current build
# directory. Argument name is name under which the resources can be explicitly
# loaded. Variable `name` contains compiled resource filename, which is then
# used for compiling library / executable. Example usage:
#  corrade_add_resource(app_resources resources.conf)
#  add_executable(app source1 source2 ... ${app_resources})
#
# Add dynamic plugin.
#  corrade_add_plugin(plugin_name debug_install_dir release_install_dir
#                     metadata_file sources...)
# The macro adds preprocessor directive CORRADE_DYNAMIC_PLUGIN. Additional
# libraries can be linked in via target_link_libraries(plugin_name ...). If
# debug_install_dir is set to CMAKE_CURRENT_BINARY_DIR (e.g. for testing
# purposes), the files are copied directly, without the need to perform install
# step. Note that the files are actually put into configuration-based
# subdirectory, i.e. ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}. See
# documentation of CMAKE_CFG_INTDIR variable for more information.
#
#
# Add static plugin.
#  corrade_add_static_plugin(plugin_name install_dir metadata_file
#                            sources...)
# The macro adds preprocessor directive CORRADE_STATIC_PLUGIN. Additional
# libraries can be linked in via target_link_libraries(plugin_name ...). If
# install_dir is set to CMAKE_CURRENT_BINARY_DIR (e.g. for testing purposes),
# no installation rules are added.
#
# Note that plugins built in debug configuration (e.g. with CMAKE_BUILD_TYPE
# set to Debug) have "-d" suffix to make it possible to have both debug and
# release plugins installed alongside each other.
#
#
# Find corresponding DLLs for library files.
#  corrade_find_dlls_for_libs(<VAR> libs...)
# Available only on Windows, for all *.lib files tries to find corresponding
# DLL file. Useful for bundling dependencies for e.g. WinRT packages.
#
#
# Additionally these variables are defined for internal usage:
#  CORRADE_INCLUDE_DIR              - Root include dir
#  CORRADE_INTERCONNECT_LIBRARY     - Interconnect library (w/o
#   dependencies)
#  CORRADE_UTILITY_LIBRARY          - Utility library (w/o dependencies)
#  CORRADE_PLUGINMANAGER_LIBRARY    - Plugin manager library (w/o
#   dependencies)
#  CORRADE_TESTSUITE_LIBRARY        - TestSuite library (w/o dependencies)
#  CORRADE_*_LIBRARY_DEBUG          - Debug version of given library, if found
#  CORRADE_*_LIBRARY_RELEASE        - Release version of given library, if
#                                     found
#  CORRADE_USE_MODULE               - Path to UseCorrade.cmake module (included
#                                     automatically)
#  CORRADE_TESTSUITE_XCTEST_RUNNER  - Path to XCTestRunner.mm.in file
#

#
#   This file is part of Corrade.
#
#   Copyright © 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016
#             Vladimír Vondruš <mosra@centrum.cz>
#
#   Permission is hereby granted, free of charge, to any person obtaining a
#   copy of this software and associated documentation files (the "Software"),
#   to deal in the Software without restriction, including without limitation
#   the rights to use, copy, modify, merge, publish, distribute, sublicense,
#   and/or sell copies of the Software, and to permit persons to whom the
#   Software is furnished to do so, subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be included
#   in all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
#   THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
#   DEALINGS IN THE SOFTWARE.
#

# Libraries
foreach(_component Interconnect Utility PluginManager TestSuite)
    string(TOUPPER ${_component} _COMPONENT)

    # Try to find both debug and release version
    find_library(CORRADE_${_COMPONENT}_LIBRARY_DEBUG Corrade${_component}-d)
    find_library(CORRADE_${_COMPONENT}_LIBRARY_RELEASE Corrade${_component})

    # Set the _LIBRARY variable based on what was found
    if(CORRADE_${_COMPONENT}_LIBRARY_DEBUG AND CORRADE_${_COMPONENT}_LIBRARY_RELEASE)
        set(CORRADE_${_COMPONENT}_LIBRARY
            debug ${CORRADE_${_COMPONENT}_LIBRARY_DEBUG}
            optimized ${CORRADE_${_COMPONENT}_LIBRARY_RELEASE})
    elseif(CORRADE_${_COMPONENT}_LIBRARY_DEBUG)
        set(CORRADE_${_COMPONENT}_LIBRARY ${CORRADE_${_COMPONENT}_LIBRARY_DEBUG})
    elseif(CORRADE_${_COMPONENT}_LIBRARY_RELEASE)
        set(CORRADE_${_COMPONENT}_LIBRARY ${CORRADE_${_COMPONENT}_LIBRARY_RELEASE})
    endif()

    mark_as_advanced(CORRADE_${_COMPONENT}_LIBRARY_DEBUG
        CORRADE_${_COMPONENT}_LIBRARY_RELEASE
        CORRADE_${_COMPONENT}_LIBRARY)
endforeach()

# RC executable
find_program(CORRADE_RC_EXECUTABLE corrade-rc)

# Include dir
find_path(CORRADE_INCLUDE_DIR
    NAMES Corrade/PluginManager Corrade/Utility)

# CMake module dir
find_path(_CORRADE_MODULE_DIR
    NAMES UseCorrade.cmake CorradeLibSuffix.cmake
    PATH_SUFFIXES share/cmake/Corrade)

# Configuration file
find_file(_CORRADE_CONFIGURE_FILE configure.h
    HINTS ${CORRADE_INCLUDE_DIR}/Corrade/)

# We need to open configure.h file from CORRADE_INCLUDE_DIR before we check for
# the components. Bail out with proper error message if it wasn't found. The
# complete check with all components is further below.
if(NOT CORRADE_INCLUDE_DIR)
    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(Corrade
        REQUIRED_VARS CORRADE_INCLUDE_DIR _CORRADE_CONFIGURE_FILE)
endif()

# Read flags from fonfiguration
file(READ ${_CORRADE_CONFIGURE_FILE} _corradeConfigure)
set(_corradeFlags
    GCC47_COMPATIBILITY
    MSVC2015_COMPATIBILITY
    BUILD_DEPRECATED
    BUILD_STATIC
    TARGET_UNIX
    TARGET_APPLE
    TARGET_IOS
    TARGET_WINDOWS
    TARGET_WINDOWS_RT
    TARGET_NACL
    TARGET_NACL_NEWLIB
    TARGET_NACL_GLIBC
    TARGET_EMSCRIPTEN
    TARGET_ANDROID
    TESTSUITE_TARGET_XCTEST)
foreach(_corradeFlag ${_corradeFlags})
    string(FIND "${_corradeConfigure}" "#define CORRADE_${_corradeFlag}" _corrade_${_corradeFlag})
    if(NOT _corrade_${_corradeFlag} EQUAL -1)
        set(CORRADE_${_corradeFlag} 1)
    endif()
endforeach()

# XCTest runner file
if(CORRADE_TESTSUITE_TARGET_XCTEST)
    find_file(CORRADE_TESTSUITE_XCTEST_RUNNER XCTestRunner.mm.in
        PATH_SUFFIXES share/corrade/TestSuite)
    set(CORRADE_TESTSUITE_XCTEST_RUNNER_NEEDED CORRADE_TESTSUITE_XCTEST_RUNNER)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Corrade DEFAULT_MSG
    CORRADE_UTILITY_LIBRARY
    CORRADE_INTERCONNECT_LIBRARY
    CORRADE_PLUGINMANAGER_LIBRARY
    CORRADE_TESTSUITE_LIBRARY
    CORRADE_INCLUDE_DIR
    CORRADE_RC_EXECUTABLE
    _CORRADE_MODULE_DIR
    _CORRADE_CONFIGURE_FILE
    ${CORRADE_TESTSUITE_XCTEST_RUNNER_NEEDED})

set(CORRADE_INCLUDE_DIRS ${CORRADE_INCLUDE_DIR})
set(CORRADE_UTILITY_LIBRARIES ${CORRADE_UTILITY_LIBRARY})
set(CORRADE_INTERCONNECT_LIBRARIES ${CORRADE_INTERCONNECT_LIBRARY} ${CORRADE_UTILITY_LIBRARIES})
set(CORRADE_PLUGINMANAGER_LIBRARIES ${CORRADE_PLUGINMANAGER_LIBRARY} ${CORRADE_UTILITY_LIBRARIES})
set(CORRADE_TESTSUITE_LIBRARIES ${CORRADE_TESTSUITE_LIBRARY} ${CORRADE_UTILITY_LIBRARIES})
set(CORRADE_USE_MODULE ${_CORRADE_MODULE_DIR}/UseCorrade.cmake)
set(CORRADE_LIB_SUFFIX_MODULE ${_CORRADE_MODULE_DIR}/CorradeLibSuffix.cmake)

# If the configure file is somewhere else than in root include dir (e.g. when
# using CMake subproject), we need to include that dir too
if(NOT ${CORRADE_INCLUDE_DIR}/Corrade/configure.h STREQUAL ${_CORRADE_CONFIGURE_FILE})
    # Go two levels up
    get_filename_component(_CORRADE_CONFIGURE_FILE_INCLUDE_DIR ${_CORRADE_CONFIGURE_FILE} DIRECTORY)
    get_filename_component(_CORRADE_CONFIGURE_FILE_INCLUDE_DIR ${_CORRADE_CONFIGURE_FILE_INCLUDE_DIR} DIRECTORY)
    list(APPEND CORRADE_INCLUDE_DIRS ${_CORRADE_CONFIGURE_FILE_INCLUDE_DIR})
endif()

# At least static build needs this
if(CORRADE_TARGET_UNIX OR CORRADE_TARGET_NACL_GLIBC)
    set(CORRADE_PLUGINMANAGER_LIBRARIES ${CORRADE_PLUGINMANAGER_LIBRARIES} ${CMAKE_DL_LIBS})
endif()

# AndroidLogStreamBuffer class needs to be linked to log library
if(CORRADE_TARGET_ANDROID)
    set(CORRADE_UTILITY_LIBRARIES ${CORRADE_UTILITY_LIBRARIES} log)
endif()

mark_as_advanced(_CORRADE_CONFIGURE_FILE _CORRADE_MODULE_DIR)

# Finalize the finding process
include(${CORRADE_USE_MODULE})
