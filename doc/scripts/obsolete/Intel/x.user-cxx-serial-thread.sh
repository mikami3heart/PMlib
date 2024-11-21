#!/bin/bash
#	Run this job as :
#			$ sbatch x.job.sh
#
#SBATCH -p ppsq
#SBATCH -J SERIAL-THREADS
#SBATCH -o SERIAL-THREADS-%j
#SBATCH -N 1
#SBATCH --cpus-per-task=12
#SBATCH -t 00:10:00

source /opt/intel/bin/compilervars.sh intel64
export LANG=C
set -x

hostname

WKDIR=${HOME}/tmp/check_prepost_threads
mkdir -p $WKDIR
cd $WKDIR; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi
rm $WKDIR/* >/dev/null 2>&1


PAPI_DIR=${HOME}/papi/usr_local_papi/papi-5.7.0-intel
#	PAPI_LDFLAGS="-L${PAPI_DIR}/lib64 -lpapi -lpfm "
PAPI_LDFLAGS="-L${PAPI_DIR}/lib -lpapi -lpfm "
PAPI_INCLUDES="-I${PAPI_DIR}/include "

PMLIB_DIR=${HOME}/pmlib/usr_local_pmlib/prepost-intel

#	PMLIB_LDFLAGS="-L${PMLIB_DIR}/lib -lPMmpi -lpapi_ext "	# (1) for MPI version
PMLIB_LDFLAGS="-L${PMLIB_DIR}/lib -lPM -lpapi_ext "	# (2) for serial version
PMLIB_INCLUDES="-I${PMLIB_DIR}/include "	# only needed for C++ programs
#	MPI_LDFLAGS="-lmpi "

INCLUDES="${PAPI_INCLUDES} ${PMLIB_INCLUDES} "
#	LDFLAGS="${PAPI_LDFLAGS} ${PMLIB_LDFLAGS}  ${MPI_LDFLAGS} --linkfortran "
LDFLAGS="${PAPI_LDFLAGS} ${PMLIB_LDFLAGS}  ${MPI_LDFLAGS} "
#	LDFLAGS="${LDFLAGS} -lstdc++ "
#	LDFLAGS="${LDFLAGS} -Wl,'-Bstatic,-lpapi,-lpfm,-Bdynamic' -lstdc++ "

export  LD_LIBRARY_PATH=${PAPI_DIR}/lib:${LD_LIBRARY_PATH}

#	DEBUG="-DDEBUG_PRINT_MONITOR -DDEBUG_PRINT_WATCH -DDEBUG_PRINT_POWER_EXT -g "
#	DEBUG+="-DDEBUG_PRINT_PAPI -DDEBUG_PRINT_LABEL "

FFLAGS="-qopenmp ${DEBUG} -DDISABLE_MPI "
CXXFLAGS="-std=c++11 -qopenmp ${DEBUG} -DDISABLE_MPI "
CFLAGS="-std=c11 -qopenmp ${DEBUG} -DDISABLE_MPI "

#	SRCDIR=${HOME}/pmlib/src_tests/src_test_others
#	cp $SRCDIR/parallel_threadprivate.cpp     main.cpp

SRCDIR=${HOME}/pmlib/src_tests/src_test_threads
#	cp $SRCDIR/serial_thread.cpp main.cpp
#	cp $SRCDIR/test_thread.cpp main.cpp
cp $SRCDIR/parallel_thread.cpp main.cpp
cp $SRCDIR/SupportReportCPP.cpp sub.cpp
#	icpc  ${CXXFLAGS} ${INCLUDES}  sub.cpp main.cpp  ${LDFLAGS} 

icpc  ${CXXFLAGS} ${INCLUDES}  -c main.cpp  ${LDFLAGS} 
icpc  ${CXXFLAGS} ${INCLUDES}  -c sub.cpp ${LDFLAGS} 
icpc  ${CXXFLAGS} ${INCLUDES}  main.o sub.o  ${LDFLAGS} 


#	export PMLIB_REPORT=BASIC
#	export PMLIB_REPORT=DETAIL
#   export PMLIB_REPORT=FULL
#	export HWPC_CHOOSER=FLOPS
export HWPC_CHOOSER=BANDWIDTH
#	export POWER_CHOOSER=NODE

export OMP_NUM_THREADS=12
#	export OMP_NUM_THREADS=3
#	NPROCS=2
NPROCS=1

./a.out

#	cat /var/lib/slurm/spool/job${SLURM_JOBID}/slurm_script

exit

