#! /bin/bash
#	module unload TCSuite
#	module load TCSuite/GM-2.0.0-03
set -x

PACKAGE_DIR=${HOME}/pmlib/package
PMLIB_DIR=${HOME}/pmlib/usr_local_pmlib/pmlib-fx100
PMLIB_LDFLAGS="-L${PMLIB_DIR}/lib -lPMmpi "

PAPI_DIR=""
PAPI_LDFLAGS="-lpapi_ext -lpapi -lpfm "

OTF_DIR=${HOME}/otf/usr_local_otf/fx100
OTF_LDFLAGS="-lotf_ext -L${OTF_DIR}/lib -lopen-trace-format -lotfaux "

FX100LDFLAGS="-Ntl_notrt -Nfjcex"
LDFLAGS+=" ${PMLIB_LDFLAGS} ${PAPI_LDFLAGS} ${OTF_LDFLAGS} ${FX100LDFLAGS} "


PMLIB_INCLUDES="-I${PMLIB_DIR}/include "
PAPI_INCLUDES=""
# Set FX100_INCLUDES for Fortran programs only
#	FX100_INCLUDES="-I/opt/FJSVXosDevkit/sparc64fx/rfs/usr/include "
FX100_INCLUDES=""
INCLUDES+=" ${PMLIB_INCLUDES} ${PAPI_INCLUDES} ${FX100_INCLUDES} "

WK_DIR=${HOME}/work/check_pmlib
mkdir -p $WK_DIR
cd $WK_DIR; if [ $? != 0 ] ; then echo '@@@ Directory error @@@'; exit; fi
rm $WK_DIR/*

cp ${PACKAGE_DIR}/doc/src_tutorial/mxm.cpp  main.cpp


CXXFLAGS="-Kopenmp,fast -w "
CFLAGS="-std=c99 -Kopenmp,fast -w "
FCFLAGS="-Cpp -Kopenmp,fast "

mpiFCCpx ${CXXFLAGS} ${INCLUDES} -o a.out.mpi main.cpp ${LDFLAGS}

ls -go
file a.out.mpi


