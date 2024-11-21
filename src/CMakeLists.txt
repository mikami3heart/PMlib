###################################################################################
#
# PMlib - Performance Monitor Library
#
# Copyright (c) 2010-2011 VCAD System Research Program, RIKEN.
# All rights reserved.
#
# Copyright (c) 2012-2020 Advanced Institute for Computational Science(AICS), RIKEN.
# All rights reserved.
#
# Copyright (c) 2016-2020 Research Institute for Information Technology(RIIT), Kyushu University.
# All rights reserved.
#
###################################################################################


set(pm_files
       PerfCpuType.cpp
       PerfMonitor.cpp
       PerfWatch.cpp
       PerfProgFortran.cpp
       PerfProgC.cpp
       SupportReportFortran.F90
       SupportReportCPP.cpp
       SupportReportC.c)

if(with_MPI)
  add_library(PMmpi STATIC)
  target_sources(PMmpi PUBLIC ${pm_files})
  set_target_properties(PMmpi PROPERTIES LINKER_LANGUAGE CXX)
  target_link_libraries(PMmpi ${CMAKE_CXX_IMPLICIT_LINK_LIBRARIES})
else()
  add_library(PM STATIC)
  target_sources(PM PUBLIC ${pm_files})
  set_target_properties(PM PROPERTIES LINKER_LANGUAGE CXX)
  target_link_libraries(PM ${CMAKE_CXX_IMPLICIT_LINK_LIBRARIES})
endif()

# pmVersion.hをサーチするためにBINARYを先に書く
include_directories(${PROJECT_BINARY_DIR}/include)
include_directories(${PROJECT_SOURCE_DIR}/include)



if(with_PAPI)
  # papi header ファイルはPerfWatchクラスなどをコンパイルする場合にも参照される
  include_directories(${PAPI_DIR}/include)
endif()

if(with_POWER)
  include_directories(${POWER_DIR}/include)
endif()

