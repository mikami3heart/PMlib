#!/bin/bash
#	#PJM -N SPACK-STREAM-CPP
#PJM -N ALL-REPORT-STREAM-4x12
#PJM --rsc-list "rscunit=rscunit_ft01"
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=1"
#PJM --rsc-list "elapse=00:45:00"
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

WKDIR=${HOME}/tmp/check_stream/stream_cpp
mkdir -p $WKDIR
cd $WKDIR; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi
rm $WKDIR/* >/dev/null 2>&1
rm -rf output* >/dev/null 2>&1

FFLAGS="-Kfast -Kopenmp -w -Cpp -Nlst=t "
CXXFLAGS="-Nclang --std=c++11 -Kopenmp -ffj-lst=t"
CFLAGS="-Nclang --std=c11 -Kopenmp "
LDFLAGS="-lPMmpi "
LDFLAGS+="-lpapi -lpfm -lpwr --linkfortran "

SRCDIR=${HOME}/pmlib/src_tests
cp $SRCDIR/src_tests/main_stream.cpp main.cpp
cp $SRCDIR/src_subs/sub_stream.cpp sub.cpp
mpiFCC -c ${CXXFLAGS} main.cpp ${INCLUDES}
mpiFCC -c ${CXXFLAGS} sub.cpp ${INCLUDES}
mpiFCC ${CXXFLAGS}  main.o sub.o ${LDFLAGS} -SSL2BLAMP


xospastop
NPROCS=4
export OMP_NUM_THREADS=12
#	export HWPC_CHOOSER=FLOPS
export PMLIB_REPORT=DETAIL
export POWER_CHOOSER=NODE

for i in BANDWIDTH FLOPS VECTOR CACHE CYCLE LOADSTORE
do
export HWPC_CHOOSER=${i}
mpiexec -np ${NPROCS}  ./a.out
done
pwd

ls -lR
more output.*/0/*/stdout.*.0

