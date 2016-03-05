
# (the blank line is here so CMake doesn't generate documentation from it)

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

# Already included, nothing to do
if(_CORRADE_USE_INCLUDED)
    return()
endif()

# Check compiler version
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    # Don't allow to use compilers older than what compatibility mode allows
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.4.0")
        message(FATAL_ERROR "Corrade cannot be used with GCC < 4.4")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.5.0" AND NOT CORRADE_GCC44_COMPATIBILITY)
        message(FATAL_ERROR "To use Corrade with GCC 4.4, build it with GCC44_COMPATIBILITY enabled")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.6.0" AND NOT CORRADE_GCC45_COMPATIBILITY)
        message(FATAL_ERROR "To use Corrade with GCC 4.5, build it with GCC45_COMPATIBILITY enabled")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.7.0" AND NOT CORRADE_GCC46_COMPATIBILITY)
        message(FATAL_ERROR "To use Corrade with GCC 4.6, build it with GCC46_COMPATIBILITY enabled")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.8.1" AND NOT CORRADE_GCC47_COMPATIBILITY)
        message(FATAL_ERROR "To use Corrade with GCC 4.7, build it with GCC47_COMPATIBILITY enabled")
    endif()

    # Don't allow to use compiler newer than what compatibility mode allows
    if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.8.1" AND CORRADE_GCC47_COMPATIBILITY)
        message(FATAL_ERROR "GCC >=4.8.1 cannot be used if Corrade is built with GCC47_COMPATIBILITY")
    endif()
    if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.7.0" AND CORRADE_GCC46_COMPATIBILITY)
        message(FATAL_ERROR "GCC >=4.7 cannot be used if Corrade is built with GCC46_COMPATIBILITY")
    endif()
    if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.6.0" AND CORRADE_GCC45_COMPATIBILITY)
        message(FATAL_ERROR "GCC >=4.6 cannot be used if Corrade is built with GCC45_COMPATIBILITY")
    endif()
    if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.5.0" AND CORRADE_GCC44_COMPATIBILITY)
        message(FATAL_ERROR "GCC >=4.5 cannot be used if Corrade is built with GCC44_COMPATIBILITY")
    endif()
elseif(MSVC)
    # Don't allow to use compilers older than what compatibility mode allows
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "18.0")
        message(FATAL_ERROR "Corrade cannot be used with MSVC < 2013")
    elseif(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "19.0" AND NOT CORRADE_MSVC2013_COMPATIBILITY)
        message(FATAL_ERROR "To use Corrade with MSVC 2013, build it with MSVC2013_COMPATIBILITY enabled")
    elseif(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "20.0" AND NOT CORRADE_MSVC2015_COMPATIBILITY)
        message(FATAL_ERROR "To use Corrade with MSVC 2015, build it with MSVC2015_COMPATIBILITY enabled")
    endif()
endif()

# GCC/Clang-specific compiler flags
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "(Apple)?Clang" OR CORRADE_TARGET_EMSCRIPTEN)
    set(CORRADE_PEDANTIC_COMPILER_OPTIONS
        "-Wall" "-Wextra"
        "$<$<STREQUAL:$<TARGET_PROPERTY:LINKER_LANGUAGE>,CXX>:-Wold-style-cast>"
        "-Winit-self"
        "-Werror=return-type"
        "-Wmissing-declarations"
        "-pedantic"
        "-fvisibility=hidden")

    # Some flags are not yet supported everywhere
    # TODO: do this with check_c_compiler_flags()
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        if(NOT "${CMAKE_CXX_COMPILER_VERSION}" VERSION_LESS "4.7.0")
            list(APPEND CORRADE_PEDANTIC_COMPILER_OPTIONS "$<$<STREQUAL:$<TARGET_PROPERTY:LINKER_LANGUAGE>,CXX>:-Wzero-as-null-pointer-constant>")
        endif()
        if(NOT "${CMAKE_CXX_COMPILER_VERSION}" VERSION_LESS "4.6.0")
            list(APPEND CORRADE_PEDANTIC_COMPILER_OPTIONS "-Wdouble-promotion")
        endif()
    endif()

    # Disable `-pedantic` for GCC 4.4.3 on NaCl to avoid excessive warnings
    # about "comma at the end of enumeration list". My own GCC 4.4.7 doesn't
    # emit these warnings.
    if(CORRADE_GCC44_COMPATIBILITY AND CORRADE_TARGET_NACL)
        list(REMOVE_ITEM CORRADE_PEDANTIC_COMPILER_OPTIONS "-pedantic")
    endif()

# MSVC-specific compiler flags
elseif(MSVC)
    set(CORRADE_PEDANTIC_COMPILER_OPTIONS
        # Enable extra warnings (similar to -Wall)
        "/W4"

        # "conditional expression is constant", fires in `do while(false)`,
        # i.e. in all assertions and tests. Does it look like I put that false
        # there by mistake?
        "/wd4127"

        # "needs to have dll-interface to be used by clients", as the fix for
        # that would effectively prevent using STL completely.
        "/wd4251"

        # "new behavior: elements of array will be default initialized".
        # YES. YES I KNOW WHAT I'M DOING.
        "/wd4351"

        # "previous versions of the compiler did not override when parameters
        # only differed by const/volatile qualifiers". Okay. So you had bugs.
        # And?
        "/wd4373"

        # "default constructor could not be generated/can never be
        # instantiated". Apparently it can.
        "/wd4510"
        "/wd4610"

        # "assignment operator could not be generated". Do I want one? NO I
        # DON'T.
        "/wd4512"

        # "no suitable definition for explicit template instantiation". No. The
        # problem is apparently that I'm having the definitions in *.cpp file
        # and instantiating them explicitly. Common practice here.
        "/wd4661"

        # "unreachable code". *Every* assertion has return after std::abort().
        # So?
        "/wd4702"

        # "assignment within conditional expression". It's not my problem that
        # it doesn't get the hint with extra parentheses (`if((a = b))`).
        "/wd4706"

        # "forcing value to bool 'true' or 'false' (performance warning)". So
        # what. I won't wrap everything in bool(). This is a _language feature_,
        # dammit.
        "/wd4800"

        # "dllexport and extern are incompatible on an explicit instantiation".
        # Why the error is emitted only on classes? Functions are okay with
        # dllexport extern?!
        "/wd4910")
    set(CORRADE_PEDANTIC_COMPILER_DEFINITIONS
        # Disabling warning for not using "secure-but-not-standard" STL algos
        "_CRT_SECURE_NO_WARNINGS" "_SCL_SECURE_NO_WARNINGS"

        # Disabling all minmax nonsense macros
        "NOMINMAX"

        # Disabling GDI and other mud in windows.h
        "WIN32_LEAN_AND_MEAN")
endif()

define_property(TARGET PROPERTY CORRADE_CXX_STANDARD INHERITED
    BRIEF_DOCS "C++ standard to require for given target"
    FULL_DOCS "Sets compiler-specific flags to enable C++11 or later standard
        when building given target or targets in given directory. Set in
        combination with INTERFACE_CORRADE_CXX_STANDARD to force the standard
        also on users of given target.")
define_property(TARGET PROPERTY INTERFACE_CORRADE_CXX_STANDARD INHERITED
    BRIEF_DOCS "C++ standard to require for users of given target"
    FULL_DOCS "Sets compiler-specific flags to enable C++11 or later standard
        when using given target or targets in given directory.")
define_property(TARGET PROPERTY CORRADE_USE_PEDANTIC_FLAGS INHERITED
    BRIEF_DOCS "Use pedantic compiler/linker flags"
    FULL_DOCS "Enables additional pedantic C, C++ and linker flags on given
        targets or directories.")

# Enable C++11 on GCC/Clang if CORRADE_CXX_STANDARD is set to 11 on the target.
# Does nothing in case the user specified CXX_STANDARD property or put "-std="
# in CMAKE_CXX_FLAGS nothing would be added. It doesn't cover adding flags
# using target_compile_options(), though.
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "(Apple)?Clang" OR CORRADE_TARGET_EMSCRIPTEN AND NOT CMAKE_CXX_FLAGS MATCHES "-std=")
    set_property(DIRECTORY APPEND PROPERTY COMPILE_OPTIONS "$<$<AND:$<NOT:$<BOOL:$<TARGET_PROPERTY:CXX_STANDARD>>>,$<STREQUAL:$<TARGET_PROPERTY:CORRADE_CXX_STANDARD>,11>>:-std=c++11>")
endif()

# On-demand pedantic compiler flags
set_property(DIRECTORY APPEND PROPERTY COMPILE_OPTIONS "$<$<BOOL:$<TARGET_PROPERTY:CORRADE_USE_PEDANTIC_FLAGS>>:${CORRADE_PEDANTIC_COMPILER_OPTIONS}>")
set_property(DIRECTORY APPEND PROPERTY COMPILE_DEFINITIONS "$<$<BOOL:$<TARGET_PROPERTY:CORRADE_USE_PEDANTIC_FLAGS>>:${CORRADE_PEDANTIC_COMPILER_DEFINITIONS}>")

# Provide CORRADE_CXX_FLAGS for backwards compatibility
if(CORRADE_BUILD_DEPRECATED)
    if(CORRADE_PEDANTIC_COMPILER_DEFINITIONS)
        string(REPLACE ";" " -D" CORRADE_CXX_FLAGS "-D${CORRADE_PEDANTIC_COMPILER_DEFINITIONS}")
    endif()
    string(REPLACE ";" " " CORRADE_CXX_FLAGS "${CORRADE_CXX_FLAGS}${CORRADE_PEDANTIC_COMPILER_OPTIONS}")
endif()

# Provide a way to distinguish between debug and release builds via
# preprocessor define
set_property(DIRECTORY APPEND PROPERTY COMPILE_DEFINITIONS "$<$<CONFIG:Debug>:CORRADE_IS_DEBUG_BUILD>")

function(corrade_add_test test_name)
    # Get DLL and path lists
    foreach(arg ${ARGN})
        if(${arg} STREQUAL LIBRARIES)
            set(__DOING_LIBRARIES ON)
        else()
            if(__DOING_LIBRARIES)
                set(libraries ${libraries} ${arg})
            else()
                set(sources ${sources} ${arg})
            endif()
        endif()
    endforeach()

    add_executable(${test_name} ${sources})
    target_link_libraries(${test_name} ${libraries} Corrade::TestSuite)
    if(CORRADE_TARGET_EMSCRIPTEN)
        # Emscripten needs to have exceptions enabled for TestSuite to work
        # properly
        set_target_properties(${test_name} PROPERTIES LINK_FLAGS "-s DISABLE_EXCEPTION_CATCHING=0")
        find_package(NodeJs REQUIRED)
        add_test(NAME ${test_name} COMMAND NodeJs::NodeJs --stack-trace-limit=0 $<TARGET_FILE:${test_name}>)
    else()
        add_test(${test_name} ${test_name})
    endif()
endfunction()

function(corrade_add_resource name configurationFile)
    # Parse dependencies from the file
    set(dependencies )
    set(filenameRegex "^[ \t]*filename[ \t]*=[ \t]*\"?([^\"]+)\"?[ \t]*$")
    get_filename_component(configurationFilePath ${configurationFile} PATH)
    file(STRINGS "${configurationFile}" files REGEX ${filenameRegex})
    foreach(file ${files})
        string(REGEX REPLACE ${filenameRegex} "\\1" filename "${file}")
        if(NOT IS_ABSOLUTE "${filename}" AND configurationFilePath)
            set(filename "${configurationFilePath}/${filename}")
        endif()
        list(APPEND dependencies "${filename}")
    endforeach()

    # Force IDEs display also the resource files in project view
    add_custom_target(${name}-dependencies SOURCES ${dependencies})

    # Output file name
    set(out "${CMAKE_CURRENT_BINARY_DIR}/resource_${name}.cpp")
    set(outDepends "${CMAKE_CURRENT_BINARY_DIR}/resource_${name}.depends")

    # Use configure_file() to trick CMake to re-run and update the dependency
    # list when the resource list file changes (otherwise it parses the file
    # only during the explicit configure step and never again, thus additions/
    # deletions are not recognized automatically)
    configure_file(${configurationFile} ${outDepends} COPYONLY)

    # Run command
    add_custom_command(
        OUTPUT "${out}"
        COMMAND Corrade::rc ${name} "${configurationFile}" "${out}"
        DEPENDS Corrade::rc ${outDepends} ${dependencies} ${name}-dependencies
        COMMENT "Compiling data resource file ${out}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")

    # Save output filename
    set(${name} "${out}" PARENT_SCOPE)
endfunction()

function(corrade_add_plugin plugin_name debug_install_dir release_install_dir metadata_file)
    # Create dynamic library and bring all needed options along
    if(CORRADE_TARGET_WINDOWS)
        add_library(${plugin_name} SHARED ${ARGN})
    else()
        add_library(${plugin_name} MODULE ${ARGN})
    endif()
    set_target_properties(${plugin_name} PROPERTIES CORRADE_CXX_STANDARD 11)
    target_compile_definitions(${plugin_name} PRIVATE "CORRADE_DYNAMIC_PLUGIN")
    target_include_directories(${plugin_name} PUBLIC $<TARGET_PROPERTY:Corrade::PluginManager,INTERFACE_INCLUDE_DIRECTORIES>)

    # Plugins don't have any prefix (e.g. 'lib' on Linux)
    set_target_properties(${plugin_name} PROPERTIES PREFIX "")

    # Enable incremental linking on the Mac OS X
    if(CORRADE_TARGET_APPLE)
        set_target_properties(${plugin_name} PROPERTIES
            LINK_FLAGS "-undefined dynamic_lookup")
    endif()

    # Copy metadata next to the binary for testing purposes or install it both
    # somewhere
    if(${debug_install_dir} STREQUAL ${CMAKE_CURRENT_BINARY_DIR})
        add_custom_command(
            OUTPUT ${plugin_name}.conf
            COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/${metadata_file} ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/${plugin_name}.conf
            DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${metadata_file})
        add_custom_target(${plugin_name}-metadata ALL
            DEPENDS ${plugin_name}.conf
            # Force IDEs display also the metadata file in project view
            SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/${metadata_file})
    else()
        # Force IDEs display also the metadata file in project view
        add_custom_target(${plugin_name}-metadata SOURCES ${metadata_file})

        install(TARGETS ${plugin_name} DESTINATION "${debug_install_dir}"
            CONFIGURATIONS Debug)
        install(TARGETS ${plugin_name} DESTINATION "${release_install_dir}"
            CONFIGURATIONS "" None Release RelWithDebInfo MinSizeRel)
        install(FILES ${metadata_file} DESTINATION "${debug_install_dir}"
            RENAME "${plugin_name}.conf"
            CONFIGURATIONS Debug)
        install(FILES ${metadata_file} DESTINATION "${release_install_dir}"
            RENAME "${plugin_name}.conf"
            CONFIGURATIONS "" None Release RelWithDebInfo MinSizeRel)
    endif()
endfunction()

function(corrade_add_static_plugin plugin_name install_dir metadata_file)
    # Compile resources
    set(resource_file "${CMAKE_CURRENT_BINARY_DIR}/resources_${plugin_name}.conf")
    file(WRITE "${resource_file}" "group=CorradeStaticPlugin_${plugin_name}\n[file]\nfilename=\"${CMAKE_CURRENT_SOURCE_DIR}/${metadata_file}\"\nalias=${plugin_name}.conf")
    corrade_add_resource(${plugin_name} "${resource_file}")

    # Create static library and bring all needed options along
    add_library(${plugin_name} STATIC ${ARGN} ${${plugin_name}})
    set_target_properties(${plugin_name} PROPERTIES CORRADE_CXX_STANDARD 11)
    target_compile_definitions(${plugin_name} PRIVATE "CORRADE_STATIC_PLUGIN")
    target_include_directories(${plugin_name} PUBLIC $<TARGET_PROPERTY:Corrade::PluginManager,INTERFACE_INCLUDE_DIRECTORIES>)

    set_target_properties(${plugin_name} PROPERTIES DEBUG_POSTFIX "-d")

    # Install, if not into the same place
    if(NOT ${install_dir} STREQUAL ${CMAKE_CURRENT_BINARY_DIR})
        install(TARGETS ${plugin_name} DESTINATION "${install_dir}")
    endif()
endfunction()

if(CORRADE_TARGET_WINDOWS)
function(corrade_find_dlls_for_libs result)
    set(dlls )
    foreach(lib ${ARGN})
        get_filename_component(lib_dir ${lib} DIRECTORY)
        get_filename_component(lib_name ${lib} NAME_WE)
        find_file(CORRADE_DLL_FOR_${lib_name} ${lib_name}.dll HINTS ${lib_dir}/../bin)
        list(APPEND dlls ${CORRADE_DLL_FOR_${lib_name}})
    endforeach()
    set(${result} ${dlls} PARENT_SCOPE)
endfunction()
endif()

set(_CORRADE_USE_INCLUDED TRUE)
