#include <mpi.h>
#include <stdio.h>
#include <math.h>
#ifdef _OPENMP
#include <omp.h>
#endif
#include <PerfMonitor.h>
using namespace pm_lib;
extern "C" void sub_initialize_();
extern "C" void sub_sgemm_();

PerfMonitor PM;
int my_id, npes, num_threads;

int main (int argc, char *argv[])
{

	double flop_count;
	double tt, t1, t2, t3, t4;
	int i, j, loop, num_threads, iret;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &my_id);
	MPI_Comm_size(MPI_COMM_WORLD, &npes);
#ifdef _OPENMP
	num_threads  = omp_get_max_threads();
#else
	num_threads  = 1;
#endif
	fprintf(stderr, "<main> started. %d PEs x %d Threads\n", npes, num_threads);

	PM.initialize();
	//	t1=MPI_Wtime();
	PM.start("sub_initialize");
	sub_initialize_();
	PM.stop("sub_initialize");

	//	for (int i=0; i<3; i++) {
	PM.start("sub_sgemm");
	sub_sgemm_();
	PM.stop("sub_sgemm");
	//	}

	//	t2=MPI_Wtime();
	//	MPI_Barrier(MPI_COMM_WORLD);
	//	fprintf(stderr, "<main> finished in %f seconds\n", t2-t1);

	PM.report(stdout);

	MPI_Finalize();
	return 0;
}

