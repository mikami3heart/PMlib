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

include_directories(${PAPI_DIR}/include)
link_directories(${PAPI_DIR}/lib64)

C99()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DSTATIC_PAPI_EVENTS_TABLE -D_REENTRANT -D_GNU_SOURCE")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DUSE_COMPILER_TLS  -DPAPI_NO_MEMORY_MANAGEMENT -DUSE_PAPI")

include_directories(${PAPI_DIR}/include)
if(with_MPI)
target_sources(PMmpi PUBLIC papi_ext.c)
else()
target_sources(PM PUBLIC papi_ext.c)
endif()

