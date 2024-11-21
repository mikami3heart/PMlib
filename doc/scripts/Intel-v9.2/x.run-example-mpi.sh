#!/bin/bash
# (Run this job as) $ sbatch x.job.sh
#   #SBATCH -p ppmq
#	#SBATCH -p ppsq
#SBATCH -p gpu1
#SBATCH -J PM-MPI-4x8
#SBATCH -o PM-MPI-4x8-%j
#SBATCH -N 1
#SBATCH --cpus-per-task=32
#SBATCH --mem 8G
#SBATCH -t 00:10:00

#	source /opt/intel/bin/compilervars.sh intel64
source /opt/intel/oneapi/setvars.sh intel64

export LANG=C
date
set -x

DIR_MPI=${HOME}/pmlib/PMlib-develop/BUILD_INTEL_MPI/example
cd ${DIR_MPI}; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi

export NCPUS=4
export OMP_NUM_THREADS=8

#   export PMLIB_REPORT=BASIC
#   export PMLIB_REPORT=DETAIL
export PMLIB_REPORT=FULL

for i in BANDWIDTH
#	for i in FLOPS BANDWIDTH VECTOR CACHE CYCLE LOADSTORE USER
do
export HWPC_CHOOSER=${i}
mpiexec -n ${NCPUS} ${DIR_MPI}/example1
#	${DIR_MPI}/example2
#	${DIR_MPI}/example3
done

date

