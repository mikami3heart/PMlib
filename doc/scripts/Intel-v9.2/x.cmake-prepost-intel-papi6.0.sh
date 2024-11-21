#!/bin/bash
#	source /opt/intel/bin/compilervars.sh intel64
source /opt/intel/oneapi/setvars.sh intel64

export LANG=C
set -x

PACKAGE_DIR=${HOME}/pmlib/PMlib-develop
PMLIB_DIR=${HOME}/pmlib/usr_local_pmlib/prepost-intel-papi6.0

#	PAPI_DIR="no"
#	PAPI_DIR="yes"	# doesn't work on fugaku
#	PAPI libraries are on
#	PAPI_DIR=${HOME}/papi/usr_local_papi/papi-5.7.0-intel
PAPI_DIR=${HOME}/papi/usr_local_papi/papi-6.0.0-intel

#	Power API libraries are NOT available on Intel prepost node
POWER_DIR="no"

OTF_DIR="no"

# option DUSE_PRECISE_TIMER is enabled inside CMakeLists.txt
CXXFLAGS="-std=c++11 -qopenmp "
#	CFLAGS="-std=c99 -qopenmp "
CFLAGS="-std=c11 -qopenmp "
FFLAGS="-fpp -qopenmp -O3 -xcommon-avx512 -unroll=0 "  # for SKYLAKE

#	DEBUG="-DDEBUG_PRINT_MONITOR -DDEBUG_PRINT_WATCH -DDEBUG_PRINT_PAPI -g "
#	DEBUG+="-DDEBUG_PRINT_PAPI_THREADS -DDEBUG_PRINT_LABEL "

# 1. Serial version

#	export CC=icc CXX=icpc F90=ifort FC=ifort
export CC=icx CXX=icpx F90=ifort FC=ifort

BUILD_DIR=${PACKAGE_DIR}/BUILD_INTEL_SERIAL
mkdir -p $BUILD_DIR
cd $BUILD_DIR; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi
rm -rf  ${BUILD_DIR}/*
cmake \
	-DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchain_intel_oneapi.cmake \
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

#	export CC=mpiicc CXX=mpiicpc F90=mpiifort FC=mpiifort
#	export I_MPI_CC=icc I_MPI_CXX=icpc I_MPI_F90=ifort I_MPI_FC=ifort

export CC=mpiicx CXX=mpiicpx F90=mpiifort FC=mpiifort
export I_MPI_CC=icx I_MPI_CXX=icpx I_MPI_F90=ifort I_MPI_FC=ifort

BUILD_DIR=${PACKAGE_DIR}/BUILD_INTEL_MPI
mkdir -p $BUILD_DIR
cd $BUILD_DIR; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi
rm -rf  ${BUILD_DIR}/*
cmake \
	-DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchain_intel_oneapi.cmake \
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

