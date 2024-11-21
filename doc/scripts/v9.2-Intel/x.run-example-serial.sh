#!/bin/bash
# (Run this job as) $ sbatch x.job.sh
#   #SBATCH -p ppmq
#	#SBATCH -p ppsq
#SBATCH -p gpu1
#SBATCH -J EXAMPLES-SERIAL
#SBATCH -o EXAMPLES-SERIAL-%j
#SBATCH -N 1
#SBATCH --cpus-per-task=36
#SBATCH --mem 8G
#SBATCH -t 00:10:00

#	source /opt/intel/bin/compilervars.sh intel64
source /opt/intel/oneapi/setvars.sh intel64

export LANG=C
set -x

DIR_SERIAL=${HOME}/pmlib/PMlib-develop/BUILD_INTEL_SERIAL/example
cd ${DIR_SERIAL}; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi

export OMP_NUM_THREADS=4

#   export PMLIB_REPORT=BASIC
#   export PMLIB_REPORT=DETAIL
export PMLIB_REPORT=FULL

for i in FLOPS
#	for i in BANDWIDTH
#	for i in FLOPS BANDWIDTH VECTOR CACHE CYCLE LOADSTORE USER
do
export HWPC_CHOOSER=${i}
${DIR_SERIAL}/example1
#	${DIR_SERIAL}/example2
#	${DIR_SERIAL}/example3
done

date
~                                                                               

