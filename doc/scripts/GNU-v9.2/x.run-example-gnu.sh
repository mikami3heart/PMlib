#!/bin/bash
# (Run this job as) $ sbatch x.job.sh
#SBATCH -p gpu1
#   #SBATCH -p ppmq
#	#SBATCH -p ppsq
#SBATCH -J EXAMPLES-GNU
#SBATCH -o EXAMPLES-GNU-%j
#SBATCH -N 1
#SBATCH --cpus-per-task=72
#SBATCH -t 00:10:00

source /vol0004/apps/oss/spack/share/spack/setup-env.sh
spack load openmpi@3.1.6

set -x


DIR_SERIAL=${HOME}/pmlib/PMlib-develop/BUILD_GNU_SERIAL/example
cd ${DIR_SERIAL}; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi

export OMP_NUM_THREADS=3

#   export PMLIB_REPORT=BASIC
#   export PMLIB_REPORT=DETAIL
export PMLIB_REPORT=FULL

#	for i in FLOPS BANDWIDTH VECTOR CACHE CYCLE LOADSTORE USER
for i in BANDWIDTH
do
export HWPC_CHOOSER=${i}
${DIR_SERIAL}/example1
#	${DIR_SERIAL}/example2
#	${DIR_SERIAL}/example3
done

date
~                                                                               

