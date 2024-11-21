#!/bin/bash
#PJM -N SPACK-CLANG-V10-FLOPS
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
spack load pmlib@10.0-clang
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

FFLAGS="-Kfast -Kopenmp -w -Cpp -Nlst=t "
CXXFLAGS="-Nclang --std=c++11 -Kopenmp -ffj-lst=t"
CFLAGS="-Nclang --std=c11 -Kopenmp "
LDFLAGS="-lPMmpi -lpapi -lpfm -lpwr --linkfortran "

cp -p ${HOME}/pmlib/src_tests/src_tests/main_mix_precision.cpp main.cpp
cp -p ${HOME}/papi/src_subs/sub_mix.f90       sub.f90

mpiFCC -c ${CXXFLAGS} main.cpp
mpifrt -c ${FFLAGS} sub.f90
mpiFCC ${CXXFLAGS}  main.o sub.o ${LDFLAGS}

xospastop
NPROCS=4
export OMP_NUM_THREADS=12
export HWPC_CHOOSER=FLOPS
export PMLIB_REPORT=FULL
export POWER_CHOOSER=NODE

mpiexec -np ${NPROCS}  ./a.out
pwd
more  output.${PJM_JOBID}/0/*/std*

