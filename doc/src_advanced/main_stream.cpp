#undef _OPENMP
#include <mpi.h>
#include <stdio.h>
#include <math.h>
#ifdef _OPENMP
#include <omp.h>
#endif
#include <PerfMonitor.h>
using namespace pm_lib;
//	extern "C" void stream();
extern void stream();

PerfMonitor PM;
int my_id, npes, num_threads;

int main (int argc, char *argv[])
{

double flop_count;
double tt, t1, t2, t3, t4;
int i, j, loop, num_threads, iret;
float real_time, proc_time, mflops;
long long flpops;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &my_id);
	MPI_Comm_size(MPI_COMM_WORLD, &npes);
#ifdef _OPENMP
	num_threads  = omp_get_max_threads();
#else
	num_threads  = 1;
#endif
	if(my_id == 0) fprintf(stdout, "<main> program\n");

	PM.initialize();

	if(my_id == 0) fprintf(stdout, "starting stream benchmark\n");
	t1=MPI_Wtime();
	for (int i=0; i<30; i++)
	//	for (int i=0; i<2; i++)
	{
	PM.start("stream_check");
	stream();
	PM.stop ("stream_check");
	MPI_Barrier(MPI_COMM_WORLD);
	}
	t2=MPI_Wtime();
	if(my_id == 0) fprintf(stdout, "stream finished in %f seconds\n", t2-t1);

PM.report(stdout);

MPI_Finalize();
return 0;
}

