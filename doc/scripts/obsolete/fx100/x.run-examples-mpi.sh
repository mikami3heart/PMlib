#! /bin/bash
#PJM -N PMLIB-MPI-EXAMPLES
#PJM -L "elapse=1:00:00"
#PJM -L "node=4"
#PJM --mpi "proc=4"
#PJM -j
#PJM -S

# Start batch session
#	~/x.interactive.sh
set -x
xospastop

TEST_DIR=${HOME}/pmlib/package/BUILD_DIR/example
cd $TEST_DIR; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi

NPROCS=4
export OMP_NUM_THREADS=8
#	export OTF_TRACING=full
#	export OTF_FILENAME="trace_pmlib"

for HWPC_CHOOSER in FLOPS BANDWIDTH VECTOR CACHE LOADSTORE CYCLE USER
do
export HWPC_CHOOSER
mpiexec -n ${NPROCS} ./example4
done


