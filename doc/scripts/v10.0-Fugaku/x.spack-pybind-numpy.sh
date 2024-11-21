##!/bin/bash
#PJM -N SPACK-PYBIND-NUMPY
#PJM --rsc-list "rscunit=rscunit_ft01"
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=1"
#PJM --rsc-list "elapse=00:20:00"
#PJM --mpi "max-proc-per-node=2"
#PJM -j

##	 ./x.cmake-pybind.sh 2>&1 | tee stdout.pybind
# [compute node]
date
echo calling shell script: $0

source /vol0004/apps/oss/spack/share/spack/setup-env.sh
spack load python@3.11.6%fj@4.11.1/fhakchp arch=linux-rhel8-a64fx
spack load py-pip@23.1.2%fj@4.11.1/hvopmis arch=linux-rhel8-a64fx
spack load py-numpy@1.25.2/dgmiy5n
spack load pmlib@10.0-pybind
export LD_LIBRARY_PATH=/lib64:$LD_LIBRARY_PATH  # to avoid "xos LPG 2002" warning

set -x
export LANG=C

#	PACKAGE_DIR=${HOME}/pmlib/PMlib-pybind
#	PMLIB_DIR=${HOME}/pmlib/usr_local_pmlib/fugaku-pybind
#	LD_LIBRARY_PATH=${PMLIB_DIR}/lib:${LD_LIBRARY_PATH}
#	export LD_LIBRARY_PATH
#	PYTHONPATH=${PMLIB_DIR}/lib:${PYTHONPATH}
#	export PYTHONPATH
echo LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
echo PYTHONPATH=${PYTHONPATH}

nm -g ${PMLIB_DIR}/lib/pyPerfMonitor.*.so | grep PerfMonitor

WKDIR=${HOME}/tmp/check_pmlib_pybind_numpy
mkdir -p $WKDIR
cd $WKDIR; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi
rm $WKDIR/*

xospastop
export PMLIB_REPORT=FULL	# BASIC, DETAIL, FULL
export HWPC_CHOOSER=FLOPS	# FLOPS, VECTOR, BANDWIDTH, CACHE, LOATSTORE, CYCLE
export POWER_CHOOSER=NUMA	# NODE, NUMA, PARTS
export OMP_NUM_THREADS=48

echo --- `date` --
time python3 ${HOME}/pmlib/src_tests/src_tests/python_numpy_matmul.py
sleep 1
ls -ltr
cat perf-report.txt
echo --- `date` ---


