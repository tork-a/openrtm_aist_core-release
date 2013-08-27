cmake_minimum_required(VERSION 2.8.3)
project(openrtm_aist)

## Find catkin macros and libraries
find_package(catkin REQUIRED)

# Compile OpenRTM
execute_process(
  COMMAND sh -c "test -e ${CATKIN_DEVEL_PREFIX}/lib/${PROJECT_NAME} || rm -f ${PROJECT_SOURCE_DIR}/installed"
  COMMAND cmake -E chdir ${PROJECT_SOURCE_DIR} make -f Makefile.openrtm_aist INSTALL_DIR=${CATKIN_DEVEL_PREFIX} VERBOSE=1
  RESULT_VARIABLE _make_failed)
if (_make_failed)
  message(FATAL_ERROR "Compile openrtm_aist failed: ${_make_failed}")
endif(_make_failed)
  # binary files intentionally goes to ${CATKIN_PACKAGE_DESTINATION}/bin
execute_process(
  COMMAND sh -c "test -e ${CATKIN_DEVEL_PREFIX}/lib/${PROJECT_NAME}/bin || (mkdir -p ${CATKIN_DEVEL_PREFIX}/lib/${PROJECT_NAME}; mv ${CATKIN_DEVEL_PREFIX}/bin/ ${CATKIN_DEVEL_PREFIX}/lib/${PROJECT_NAME})"
  OUTPUT_VARIABLE _copy_bin)
message("${_copy_bin}")



###################################
## catkin specific configuration ##
###################################

# fake add_library for catkin_package
add_library(RTC  SHARED IMPORTED)
add_library(coil SHARED IMPORTED)
set_target_properties(RTC  PROPERTIES IMPORTED_IMPLIB ${CATKIN_DEVEL_PREFIX}/lib/libRTC.so )
set_target_properties(coil PROPERTIES IMPORTED_IMPLIB ${CATKIN_DEVEL_PREFIX}/lib/libcoil.so)

#fake catkin_package
file(MAKE_DIRECTORY ${CATKIN_DEVEL_PREFIX}/include)
file(MAKE_DIRECTORY ${CATKIN_DEVEL_PREFIX}/include/coil-1.1)
file(MAKE_DIRECTORY ${CATKIN_DEVEL_PREFIX}/include/openrtm-1.1)
file(MAKE_DIRECTORY ${CATKIN_DEVEL_PREFIX}/include/openrtm-1.1/rtm/idl)
set(${PROJECT_NAME}_EXPORTED_TARGETS compile_openrtm)

# catkin_package
catkin_package(
  DEPENDS omniorb
  INCLUDE_DIRS ${CATKIN_DEVEL_PREFIX}/include ${CATKIN_DEVEL_PREFIX}/include/coil-1.1 ${CATKIN_DEVEL_PREFIX}/include/openrtm-1.1 ${CATKIN_DEVEL_PREFIX}/include/openrtm-1.1/rtm/idl
  LIBRARIES RTC coil
  SKIP_CMAKE_CONFIG_GENERATION
  SKIP_PKG_CONFIG_GENERATION
)

#############
## Install ##
#############

## Mark cpp header files for installation
install(DIRECTORY ${CATKIN_DEVEL_PREFIX}/include
  DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
)

# bin goes lib/openrtm_aist so that it can be invoked from rosrun
install(DIRECTORY ${CATKIN_DEVEL_PREFIX}/bin
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
  USE_SOURCE_PERMISSIONS  # set executable
)

install(DIRECTORY ${CATKIN_DEVEL_PREFIX}/etc
  DESTINATION ${CATKIN_PACKAGE_ETC_DESTINATION}
)

install(DIRECTORY ${CATKIN_DEVEL_PREFIX}/lib/ # lib will create devel/lib/lib/*, so lib/ is important
  DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
  USE_SOURCE_PERMISSIONS  # set executable
)

install(DIRECTORY ${CATKIN_DEVEL_PREFIX}/share/openrtm-1.1
  DESTINATION ${CATKIN_GLOBAL_SHARE_DESTINATION}
)


#debug codes
#get_cmake_property(_variableNames VARIABLES)
#foreach (_variableName ${_variableNames})
#  message(STATUS "${_variableName}=${${_variableName}}")
#endforeach()
# CODE to fix path in rtm-config and openrtm-aist.pc
install(CODE
 "execute_process(COMMAND echo \" fix \$ENV{DESTDIR}/${CATKIN_PACKAGE_BIN_DESTINATION}/rtm-config\")
  execute_process(COMMAND echo \" sed s@${CATKIN_DEVEL_PREFIX}@${CMAKE_INSTALL_PREFIX}@g\")
  execute_process(COMMAND sed -i s@^prefix=\"${CATKIN_DEVEL_PREFIX}\"@prefix=\"${CMAKE_INSTALL_PREFIX}/include/${PROJECT_NAME}\"@g \$ENV{DESTDIR}/${CATKIN_PACKAGE_BIN_DESTINATION}/rtm-config) # basic
  execute_process(COMMAND sed -i s@${CATKIN_DEVEL_PREFIX}@${CMAKE_INSTALL_PREFIX}@g \$ENV{DESTDIR}/${CATKIN_PACKAGE_BIN_DESTINATION}/rtm-config) # basic
  execute_process(COMMAND sed -i s@exec_prefix=@exec_prefix=\"${CMAKE_INSTALL_PREFIX}\"\\ \\\#@g \$ENV{DESTDIR}/${CATKIN_PACKAGE_BIN_DESTINATION}/rtm-config) # for -cflags
  ")


install(CODE
  "execute_process(COMMAND echo \"fix openrtm-aist.pc path ${CATKIN_DEVEL_PREFIX} -> ${CMAKE_INSTALL_PREFIX}\")
  execute_process(COMMAND sed -i s@exec_prefix=@exec_prefix=${CMAKE_INSTALL_PREFIX}\\ \\\#@g $ENV{DESTDIR}/${CATKIN_PACKAGE_LIB_DESTINATION}/pkgconfig/openrtm-aist.pc) # for --libs
   execute_process(COMMAND sed -i s@${CATKIN_DEVEL_PREFIX}@${CMAKE_INSTALL_PREFIX}@g $ENV{DESTDIR}/${CATKIN_PACKAGE_LIB_DESTINATION}/pkgconfig/openrtm-aist.pc) # basic
   execute_process(COMMAND sed -i s@{prefix}@{prefix}/include/openrtm_aist@g $ENV{DESTDIR}/${CATKIN_PACKAGE_LIB_DESTINATION}/pkgconfig/openrtm-aist.pc) # basic
")

