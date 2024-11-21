##!/bin/bash
#PJM -N SPACK-PYBIND-MPI4PY
#PJM --rsc-list "rscunit=rscunit_ft01"
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=1"
#PJM --rsc-list "elapse=00:20:00"
#PJM --mpi "max-proc-per-node=4"
#PJM -j
date
echo calling shell script: $0
# [compute node]
source /vol0004/apps/oss/spack/share/spack/setup-env.sh
spack load python@3.11.6%fj@4.11.1/fhakchp arch=linux-rhel8-a64fx
spack load py-pip@23.1.2%fj@4.11.1/hvopmis arch=linux-rhel8-a64fx
spack load py-numpy@1.25.2/dgmiy5n
spack load py-mpi4py@3.1.4/bwznyvi
spack load pmlib@10.0-pybind
export LD_LIBRARY_PATH=/lib64:$LD_LIBRARY_PATH	# to avoid "xos LPG 2002" warning

set -x
export LANG=C

#	PACKAGE_DIR=${HOME}/pmlib/PMlib-pybind
#	PMLIB_DIR=${HOME}/pmlib/usr_local_pmlib/fugaku-pybind
#	LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PMLIB_DIR}/lib
#	export LD_LIBRARY_PATH
#	PYTHONPATH=${PMLIB_DIR}/lib:${PYTHONPATH}
#	export PYTHONPATH


WKDIR=${HOME}/tmp/check_pmlib/pybind_mpi4py
mkdir -p $WKDIR
cd $WKDIR; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi
rm $WKDIR/*
rm -rf $WKDIR/output.* >/dev/null 2>&1
xospastop
export HWPC_CHOOSER=FLOPS	# FLOPS, VECTOR, BANDWIDTH, CACHE, LOATSTORE, CYCLE
export PMLIB_REPORT=FULL	# BASIC, DETAIL, FULL
export POWER_CHOOSER=PARTS	# NODE, NUMA, PARTS
export OMP_NUM_THREADS=12

echo --- `date` --
mpiexec -np 4 python3 ${HOME}/pmlib/src_tests/src_tests/python_mpi4py.py

ls -goR
more  output.${PJM_JOBID}/*/*/std*
more  perf-report.txt
echo --- `date` ---


