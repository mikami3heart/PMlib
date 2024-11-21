#undef _OPENMP
#include <mpi.h>
#include <stdio.h>
#include <math.h>
#ifdef _OPENMP
#include <omp.h>
#endif
#include <PerfMonitor.h>
using namespace pm_lib;
PerfMonitor PM;

extern "C" void sub_init_( int * );
extern "C" void sub_dmix_( int * );
extern "C" void sub_smix_( int * );
extern "C" void sub_hmix_( int * );

int main (int argc, char *argv[])
{
	int my_id, npes, num_threads;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &my_id);
	MPI_Comm_size(MPI_COMM_WORLD, &npes);
#ifdef _OPENMP
	num_threads  = omp_get_max_threads();
#else
	num_threads  = 1;
#endif
	if(my_id == 0) fprintf(stderr, "<main> program\n");

	PM.initialize();

    int msize=2000;
    sub_init_(&msize);


    for (int i=0; i<10; i++)
	{
	PM.start("sub_dmix");
	sub_dmix_(&msize);
	PM.stop ("sub_dmix");

	PM.start("sub_smix");
	sub_smix_(&msize);
	PM.stop ("sub_smix");

	PM.start("sub_hmix");
	sub_hmix_(&msize);
	PM.stop ("sub_hmix");
	}


	PM.report(stderr);

	MPI_Finalize();
return 0;
}

