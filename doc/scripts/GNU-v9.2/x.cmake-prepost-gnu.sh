#!/bin/bash
source /vol0004/apps/oss/spack/share/spack/setup-env.sh
spack load openmpi@3.1.6	# this module is openmp for Intel Skylake

echo running shell script $0
set -x

PACKAGE_DIR=${HOME}/pmlib/PMlib-develop
PMLIB_DIR=${HOME}/pmlib/usr_local_pmlib/prepost-gnu

#	PAPI_DIR="no"
#	PAPI_DIR="yes"	# doesn't work on fugaku
#	PAPI libraries are on
#	PAPI_DIR=${HOME}/papi/usr_local_papi/papi-5.7.0-gnu
#	PAPI_DIR="yes"	# for Intel node
PAPI_DIR=/usr/lib64

#	Power API libraries are NOT available on Intel prepost node
POWER_DIR="no"

OTF_DIR="no"

# option DUSE_PRECISE_TIMER is enabled inside CMakeLists.txt
CXXFLAGS="-std=c++11 -fopenmp -w "
CFLAGS="-std=c99 -fopenmp -w "
FCFLAGS="-fpp -fopenmp -O3 -w -Wno-tabs "

#	DEBUG="-DDEBUG_PRINT_MONITOR -DDEBUG_PRINT_WATCH -DDEBUG_PRINT_PAPI -g "
#	DEBUG+="-DDEBUG_PRINT_PAPI_THREADS -DDEBUG_PRINT_LABEL "

# 1. Serial version

export CC=gcc CXX=g++ F90=gfortran FC=gfortran


BUILD_DIR=${PACKAGE_DIR}/BUILD_GNU_SERIAL
mkdir -p $BUILD_DIR
cd $BUILD_DIR; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi
rm -rf  ${BUILD_DIR}/*
cmake \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS} ${DEBUG}" \
	-DCMAKE_C_FLAGS="${CFLAGS} ${DEBUG}" \
	-DCMAKE_Fortran_FLAGS="${FFLAGS} ${DEBUG}" \
	-DINSTALL_DIR=${PMLIB_DIR} \
	-Denable_OPENMP=yes \
	-Dwith_MPI=no \
	-Denable_Fortran=yes \
	-Dwith_example=yes \
	-Dwith_PAPI=${PAPI_DIR} \
	-Dwith_POWER=${POWER_DIR} \
	-Dwith_OTF=${OTF_DIR} \
	..

make VERBOSE=1
make install

# 2. MPI version

export CC=mpicc CXX=mpicxx F90=mpif90 FC=mpif90


BUILD_DIR=${PACKAGE_DIR}/BUILD_GNU_MPI
mkdir -p $BUILD_DIR
cd $BUILD_DIR; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi
rm -rf  ${BUILD_DIR}/*
cmake \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS} ${DEBUG}" \
	-DCMAKE_C_FLAGS="${CFLAGS} ${DEBUG}" \
	-DCMAKE_Fortran_FLAGS="${FFLAGS} ${DEBUG}" \
	-DINSTALL_DIR=${PMLIB_DIR} \
	-Denable_OPENMP=yes \
	-Dwith_MPI=yes \
	-Denable_Fortran=yes \
	-Dwith_example=yes \
	-Dwith_PAPI=${PAPI_DIR} \
	-Dwith_POWER=${POWER_DIR} \
	-Dwith_OTF=${OTF_DIR} \
	..

make VERBOSE=1
make install

