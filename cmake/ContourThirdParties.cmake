# This directory structure is being created by `scripts/install-deps.sh`
# and is used to inject all the dependencies the operating system's
# package manager did not provide (not found or too old version).

set(ContourThirdParties_SRCDIR ${PROJECT_SOURCE_DIR}/_deps/sources)
if(EXISTS "${ContourThirdParties_SRCDIR}/CMakeLists.txt")
    message(STATUS "Embedding 3rdparty libraries: ${ContourThirdParties_SRCDIR}")
    add_subdirectory(${ContourThirdParties_SRCDIR})
else()
    message(STATUS "No 3rdparty libraries found at ${ContourThirdParties_SRCDIR}")
endif()

set(LIST ContourThirdParties)
macro(Thirdparty_Include_If_MIssing _TARGET _PACKAGE_NAME)
    if(${_PACKAGE_NAME} STREQUAL "")
        set(${_PACKAGE_NAME} ${_TARGET})
    endif()
    if (NOT TARGET ${_TARGET})
        find_package(${_PACKAGE_NAME} REQUIRED)
        list(APPEND ContourThirdParties ${_TARGET}_SYSDEP)
        set(THIRDPARTY_BUILTIN_${_TARGET} "system package")
    else()
        list(APPEND ContourThirdParties ${_TARGET}_EMBED)
        set(THIRDPARTY_BUILTIN_${_TARGET} "embedded")
    endif()
endmacro()

# Thirdparty_Include_If_MIssing(Catch2 catch2)
# Thirdparty_Include_If_MIssing(fmt)
# Thirdparty_Include_If_MIssing(GSL)
# Thirdparty_Include_If_MIssing(range-v3)
# Thirdparty_Include_If_MIssing(termbench)
# Thirdparty_Include_If_MIssing(unicode::core)
# Thirdparty_Include_If_MIssing(yaml-cpp)
# TODO make me working
macro(ContourThirdPartiesSummary)
    message(STATUS "==============================================================================")
    message(STATUS "    Contour ThirdParties")
    message(STATUS "------------------------------------------------------------------------------")
    foreach(TP ${ContourThirdParties})
        message(STATUS "${TP}\t\t${THIRDPARTY_BUILTIN_${TP}}")
    endforeach()
endmacro()

# Now, conditionally find all dependencies that were not included above
# via find_package, usually system installed packages.

if(CONTOUR_TESTING)
    if(TARGET Catch2::Catch2WithMain)
        set(THIRDPARTY_BUILTIN_Catch2 "embedded")
    else()
        find_package(Catch2 REQUIRED)
        set(THIRDPARTY_BUILTIN_Catch2 "system package")
    endif()
endif()

if(TARGET fmt)
    set(THIRDPARTY_BUILTIN_fmt "embedded")
else()
    find_package(fmt REQUIRED)
    set(THIRDPARTY_BUILTIN_fmt "system package")
endif()

if(TARGET GSL)
    set(THIRDPARTY_BUILTIN_GSL "embedded")
else()
    set(THIRDPARTY_BUILTIN_GSL "system package")
    if (WIN32)
        # On Windows we use vcpkg and there the name is different
        find_package(Microsoft.GSL CONFIG REQUIRED)
        #target_link_libraries(main PRIVATE Microsoft.GSL::GSL)
    else()
        find_package(Microsoft.GSL REQUIRED)
    endif()
endif()

if (TARGET range-v3)
    set(THIRDPARTY_BUILTIN_range_v3 "embedded")
else()
    find_package(range-v3 REQUIRED)
    set(THIRDPARTY_BUILTIN_range_v3 "system package")
endif()

if (TARGET yaml-cpp)
    set(THIRDPARTY_BUILTIN_yaml_cpp "embedded")
else()
    find_package(yaml-cpp REQUIRED)
    set(THIRDPARTY_BUILTIN_yaml_cpp "system package")
endif()

if (TARGET harfbuzz)
    set(THIRDPARTY_BUILTIN_harfbuzz "embedded")
else()
    find_package(HarfBuzz REQUIRED)
    set(THIRDPARTY_BUILTIN_harfbuzz "system package")
endif()

if (TARGET freetype)
    set(THIRDPARTY_BUILTIN_freetype "embedded")
else()
    find_package(Freetype REQUIRED)
    set(THIRDPARTY_BUILTIN_freetype "system package")
endif()

find_package(libunicode)
if(libunicode_FOUND)
    set(THIRDPARTY_BUILTIN_unicode_core "system package (${libunicode_VERSION})")
else()
    ContourThirdParties_Embed_libunicode()
    set(THIRDPARTY_BUILTIN_unicode_core "embedded")
endif()

if(LIBTERMINAL_BUILD_BENCH_HEADLESS)
    ContourThirdParties_Embed_termbench_pro()
    if (TARGET termbench)
        set(THIRDPARTY_BUILTIN_termbench "embedded")
    else()
        find_package(termbench-pro REQUIRED)
        set(THIRDPARTY_BUILTIN_termbench "system package")
    endif()
else()
    set(THIRDPARTY_BUILTIN_termbench "(bench-headless disabled)")
endif()

find_package(boxed-cpp)
if(boxed-cpp_FOUND)
    set(THIRDPARTY_BUILTIN_boxed_cpp "system package")
else()
    ContourThirdParties_Embed_boxed_cpp()
    set(THIRDPARTY_BUILTIN_boxed_cpp "embedded")
endif()

macro(ContourThirdPartiesSummary2)
    message(STATUS "==============================================================================")
    message(STATUS "    Contour ThirdParties")
    message(STATUS "------------------------------------------------------------------------------")
    message(STATUS "Catch2              ${THIRDPARTY_BUILTIN_Catch2}")
    message(STATUS "GSL                 ${THIRDPARTY_BUILTIN_GSL}")
    message(STATUS "fmt                 ${THIRDPARTY_BUILTIN_fmt}")
    message(STATUS "freetype            ${THIRDPARTY_BUILTIN_freetype}")
    message(STATUS "harfbuzz            ${THIRDPARTY_BUILTIN_harfbuzz}")
    message(STATUS "range-v3            ${THIRDPARTY_BUILTIN_range_v3}")
    message(STATUS "yaml-cpp            ${THIRDPARTY_BUILTIN_yaml_cpp}")
    message(STATUS "termbench-pro       ${THIRDPARTY_BUILTIN_termbench}")
    message(STATUS "libunicode          ${THIRDPARTY_BUILTIN_unicode_core}")
    message(STATUS "boxed-cpp           ${THIRDPARTY_BUILTIN_boxed_cpp}")
    message(STATUS "------------------------------------------------------------------------------")
endmacro()
