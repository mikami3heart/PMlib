#!/bin/bash
#PJM -N SPACK-MIX-FLOPS
#PJM --rsc-list "rscunit=rscunit_ft01"
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=1"
#PJM --rsc-list "elapse=00:10:00"
#PJM --rsc-list "retention_state=0"
#PJM --mpi "max-proc-per-node=4"
#PJM -j
#PJM -S
# -S is for producing stats file. Remove it if you don't need stats
echo calling shell script: $0
# [compute node]
source /vol0004/apps/oss/spack/share/spack/setup-env.sh
spack load pmlib@9.2-clang
export LD_LIBRARY_PATH=/lib64:${LD_LIBRARY_PATH}  # to avoid "xos LPG 2002" warning
export C_INCLUDE_PATH=${PMLIB_DIR}/include:${C_INCLUDE_PATH}
export CPLUS_INCLUDE_PATH=${PMLIB_DIR}/include:${CPLUS_INCLUDE_PATH}

date
hostname
export LANG=C
echo job manager reserved the following resources
echo PJM_NODE         : ${PJM_NODE}
echo PJM_MPI_PROC     : ${PJM_MPI_PROC}
echo PJM_PROC_BY_NODE : ${PJM_PROC_BY_NODE}
set -x

WKDIR=${HOME}/tmp/check_pmlib/flops
mkdir -p $WKDIR
cd $WKDIR; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi
rm $WKDIR/* >/dev/null 2>&1
rm -rf output* >/dev/null 2>&1


#	# on Login node
#	#	PAPI_DIR=/opt/FJSVxos/devkit/aarch64/rfs/usr
#	# on compute node
#	PAPI_DIR=/usr
#	PAPI_LDFLAGS="-L${PAPI_DIR}/lib64 -lpapi -lpfm "
#	PAPI_INCLUDES="-I${PAPI_DIR}/include "

#	PMLIB_DIR=${HOME}/pmlib/usr_local_pmlib/fugaku
#	PMLIB_INCLUDES="-I${PMLIB_DIR}/include "	# needed for C++ and C programs
#	PMLIB_LDFLAGS="-L${PMLIB_DIR}/lib -lPMmpi -lpapi_ext -lpower_ext "	# (1) MPI
#	#	PMLIB_LDFLAGS="-L${PMLIB_DIR}/lib -lPM -lpapi_ext -lpower_ext "	# (2) serial

# on Login node and compute node
#	POWER_DIR="/opt/FJSVtcs/pwrm/aarch64"
#	POWER_LDFLAGS="-L${POWER_DIR}/lib64 -lpwr "
#	POWER_INCLUDES="-I${POWER_DIR}/include "

#	INCLUDES="${PAPI_INCLUDES} ${POWER_INCLUDES} ${PMLIB_INCLUDES} "
#	LDFLAGS="${PAPI_LDFLAGS} ${POWER_LDFLAGS} ${PMLIB_LDFLAGS} ${MPI_LDFLAGS} "
#	LDFLAGS+="--linkfortran "

FFLAGS="-Kfast -Kopenmp -w -Cpp -Nlst=t "
CXXFLAGS="-Nclang --std=c++11 -Kopenmp -ffj-lst=t"
CFLAGS="-Nclang --std=c11 -Kopenmp "
LDFLAGS="-lPMmpi -lpapi_ext -lpower_ext "
LDFLAGS+="-lpapi -lpfm -lpwr --linkfortran "

cp -p ${HOME}/pmlib/src_tests/src_tests/main_mix_precision.cpp main.cpp
cp -p ${HOME}/papi/src_subs/sub_mix.f90       sub.f90

mpiFCC -c ${CXXFLAGS} main.cpp
mpifrt -c ${FFLAGS} sub.f90
mpiFCC ${CXXFLAGS}  main.o sub.o ${LDFLAGS}

xospastop
#	export FLIB_FASTOMP=FALSE
#	export FLIB_CNTL_BARRIER_ERR=FALSE
#	export XOS_MMM_L_PAGING_POLICY=prepage:demand:demand

#	NPROCS=1
#	export OMP_NUM_THREADS=3
NPROCS=4
export OMP_NUM_THREADS=12
export HWPC_CHOOSER=FLOPS
export PMLIB_REPORT=FULL
export POWER_CHOOSER=NODE

mpiexec -np ${NPROCS}  ./a.out
pwd
ls -l output.${PJM_JOBID}/0/*/std*

more  output.${PJM_JOBID}/0/*/std*

