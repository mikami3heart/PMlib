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

include_directories(${POWER_DIR}/include)
include_directories(${PROJECT_BINARY_DIR}/include ${PROJECT_SOURCE_DIR}/include)

link_directories(${POWER_DIR}/lib64)

#	C99()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_GNU_SOURCE -DUSE_POWER")

if(with_MPI)
target_sources(PMmpi PUBLIC power_ext_PerfWatch.cpp)
else()
target_sources(PM PUBLIC power_ext_PerfWatch.cpp)
endif()

