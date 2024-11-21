#!/bin/bash
#PJM -N PMLIB-FORT-THREADS-4x12
#PJM --rsc-list "rscunit=rscunit_ft01,rscgrp=small,elapse=00:10:00,node=1"
#PJM --mpi "max-proc-per-node=4"
#PJM -j
#	#PJM -S
echo executing shell script: $0
echo job manager reserved the following resources
echo PJM_NODE         : ${PJM_NODE}
echo PJM_MPI_PROC     : ${PJM_MPI_PROC}
echo PJM_PROC_BY_NODE : ${PJM_PROC_BY_NODE}
date
hostname
source /vol0004/apps/oss/spack/share/spack/setup-env.sh
spack load pmlib@9.2-clang
export LANG=C
export LD_LIBRARY_PATH=/lib64:${LD_LIBRARY_PATH}  # to avoid "xos LPG 2002" warning
set -x

WKDIR=${HOME}/tmp/check_thread_pattern
mkdir -p $WKDIR
cd $WKDIR; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi
rm $WKDIR/* >/dev/null 2>&1
rm -rf $WKDIR/output.* >/dev/null 2>&1
  
FFLAGS="-Kopenmp -w -Cpp -Nlst=t "
LDFLAGS="-lPMmpi -lpapi_ext -lpower_ext -lpapi -lpfm -lpwr "	# for MPI link
#	LDFLAGS="-lPM -lpapi_ext -lpower_ext -lpapi -lpfm -lpwr "	# for serial link
LDFLAGS+="-lstdc++ "			# for fortran linker
#	LDFLAGS+="--linkfortran  "		# for C++ linker


SRCDIR=${HOME}/pmlib/src_tests/src_parallel
cp $SRCDIR/parallel_mix.f90 main.f90
mpifrt ${FFLAGS} main.f90 ${LDFLAGS}

xospastop
NPROCS=4
export OMP_NUM_THREADS=12
export PMLIB_REPORT=FULL
export HWPC_CHOOSER=FLOPS
export POWER_CHOOSER=PARTS

mpiexec -np ${NPROCS}  ./a.out
ls -lR
more  output.${PJM_JOBID}/0/*/std*

