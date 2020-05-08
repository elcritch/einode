cmake_minimum_required(VERSION 3.1)

#///////////////////////////////////////////////////////////////////#
#                              PROJECT                              #
#///////////////////////////////////////////////////////////////////#
project(erl_test
  LANGUAGES C)

# Default build type
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
  message(STATUS "No building type advertised, default to Release")
endif()

#///////////////////////////////////////////////////////////////////#
#                           DEPENDENCIES                            #
#///////////////////////////////////////////////////////////////////#
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

########################################################################
# Erlang Runtime System (ERTS) dependency
########################################################################
# add_library(socket INTERFACE IMPORTED)
# add_library(pthread INTERFACE IMPORTED)
find_package (Threads REQUIRED)


# SET(MODS ${CMAKE_SOURCE_DIR}/CMake/erlang)
# SET(CMAKE_MODULE_PATH ${MODS} ${CMAKE_MODULE_PATH})
FIND_PACKAGE(Erlang REQUIRED)
# add_library(erl_interface INTERFACE IMPORTED)


IF (ERLANG_FOUND)
    # add_library(ei INTERFACE IMPORTED)
    # # set(EI_ALL_PATHS ${ERLANG_ERTS_INCLUDE_PATH} ${ERLANG_EI_INCLUDE_PATH})
    # # message(STATUS "Setting include path ${EI_ALL_PATHS}")
    # set_property(TARGET ei PROPERTY
    # INTERFACE_INCLUDE_DIRECTORIES ${ERLANG_EI_INCLUDE_PATH})
    # set_property(TARGET ei PROPERTY
    # INTERFACE_LINK_LIBRARIES ${EI_LIBRARIES})

    # add_library(erts INTERFACE IMPORTED)
    # set_property(TARGET erts PROPERTY
    # INTERFACE_INCLUDE_DIRECTORIES ${ERLANG_ERTS_INCLUDE_PATH})
    # set_property(TARGET erts PROPERTY
    # INTERFACE_LINK_LIBRARIES ${ERTS_LIBRARIES})
    # message(STATUS "Adding libraries ${EI_LIBRARIES}")
    # include_directories(${CZMQ_INCLUDE_DIRS})
    # list(APPEND MORE_LIBRARIES ${CZMQ_LIBRARIES})
ELSE (ERLANG_FOUND)
    message( FATAL_ERROR "ERTS not found." )
ENDIF (ERLANG_FOUND)


INCLUDE_DIRECTORIES(
  ${ERLANG_EI_INCLUDE_PATH}
  ${ERLANG_ERTS_INCLUDE_PATH}
)

LINK_DIRECTORIES(
  ${ERLANG_EI_LIBRARY_PATH}
)

#///////////////////////////////////////////////////////////////////#
#                        COMPILATION OPTIONS                        #
#///////////////////////////////////////////////////////////////////#

include(cmake/compiler-flags.cmake)

set(CMAKE_C_FLAGS_RELEASE "-O3 -mtune=generic")
set(CMAKE_C_FLAGS_DEBUG
  "${COMPILER_AVALIABLE_WARNINGS} ${COMPILER_ADDRESS_SANITIZER_FLAG} ${COMPILER_UNDEFINED_SANITIZER_FLAG} -Og -g")
set(CMAKE_C_FLAGS_OPTIMIZED
  "${COMPILER_LTO_FLAG} ${COMPILER_MARCH_NATIVE} -O3")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELEASE} -g")

# Use full RPATH on build tree
set(CMAKE_SKIP_BUILD_RPATH FALSE)
# Do not build with install RPATH
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
# Set the RPATH when install
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
# Only set RPATH if the installation directory is not a system directory
LIST(FIND
  CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib"
  isSystemDir)
if("${isSystemDir}" STREQUAL "-1")
  set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
else()
  set(CMAKE_INSTALL_RPATH "")
endif()

add_subdirectory(src)
