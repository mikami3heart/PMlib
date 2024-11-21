#!/bin/bash
#	GPU-node
#SBATCH -p ppsq
#SBATCH -J PM_INTEL_MPI
#SBATCH -o PM_INTEL_MPI-%j
#	#SBATCH -o PMLIB-2Px4T-%j
#	#SBATCH -o PMLIB-4Px4T-%j
#SBATCH -N 1
#	#SBATCH -cpus-per-task=112
#SBATCH --cpus-per-task=4
#SBATCH -t 00:10:00

source /opt/intel/bin/compilervars.sh intel64
export LANG=C
set -x

hostname
env | sort| grep -i SLURM

WKDIR=${HOME}/tmp/check_prepost_cxx
mkdir -p $WKDIR
cd $WKDIR; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi
rm $WKDIR/* 


PAPI_DIR=${HOME}/papi/usr_local_papi/papi-5.7.0-intel
#	PAPI_LDFLAGS="-L${PAPI_DIR}/lib64 -lpapi -lpfm "
PAPI_LDFLAGS="-L${PAPI_DIR}/lib -lpapi -lpfm "
PAPI_INCLUDES="-I${PAPI_DIR}/include "

#	PMLIB_DIR=${HOME}/pmlib/usr_local_pmlib/fugaku-power
PMLIB_DIR=${HOME}/pmlib/usr_local_pmlib/prepost-intel

PMLIB_LDFLAGS="-L${PMLIB_DIR}/lib -lPMmpi -lpapi_ext "	# (1) for MPI version
#	PMLIB_LDFLAGS="-L${PMLIB_DIR}/lib -lPM -lpapi_ext "	# (2) for serial version
PMLIB_INCLUDES="-I${PMLIB_DIR}/include "	# only needed for C++ programs
#	MPI_LDFLAGS="-lmpi "

INCLUDES="${PAPI_INCLUDES} ${PMLIB_INCLUDES} "
#	LDFLAGS="${PAPI_LDFLAGS} ${PMLIB_LDFLAGS}  ${MPI_LDFLAGS} --linkfortran "
LDFLAGS="${PAPI_LDFLAGS} ${PMLIB_LDFLAGS}  ${MPI_LDFLAGS} "
LDFLAGS="${LDFLAGS} -lstdc++ "
#	LDFLAGS="${LDFLAGS} -Wl,'-Bstatic,-lpapi,-lpfm,-Bdynamic' -lstdc++ "

export  LD_LIBRARY_PATH=${PAPI_DIR}/lib:${LD_LIBRARY_PATH}

CXXFLAGS="-std=c++11 -O2 -qopenmp ${DEBUG} "
CFLAGS="-std=c11 -O2 -qopenmp ${DEBUG} "
FFLAGS="-O2 -qopenmp ${DEBUG} -cpp "

#	SRCDIR=${HOME}/pmlib/src_tests/src_test_others
#	cp $SRCDIR/main_usermode.cpp main.cpp

SRCDIR=${HOME}/pmlib/src_tests/src_test_threads
cp $SRCDIR/parallel_thread.cpp main.cpp
mpiicpc ${CXXFLAGS} ${INCLUDES}  main.cpp ${LDFLAGS} # choose (1)

ls -l
file ./a.out

#	export PMLIB_REPORT=BASIC
#	export PMLIB_REPORT=DETAIL
export PMLIB_REPORT=FULL
#   export HWPC_CHOOSER=FLOPS
export HWPC_CHOOSER=BANDWIDTH
#	export POWER_CHOOSER=NODE

#	export OMP_NUM_THREADS=12
export OMP_NUM_THREADS=4
NPROCS=2

mpiexec -n ${NPROCS}  ./a.out

