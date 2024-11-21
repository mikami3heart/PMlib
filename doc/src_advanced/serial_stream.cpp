#include <stdio.h>
#include <math.h>
#ifdef _OPENMP
#include <omp.h>
#endif
#include <PerfMonitor.h>
using namespace pm_lib;
//	extern "C" void stream();
extern void stream();

//	const int Max_power_knob=6;
const int Max_power_knob=5;

PerfMonitor PM;
int my_id, npes, num_threads;
int iknob, value;

int main (int argc, char *argv[])
{

double flop_count;
double tt, t1, t2, t3, t4;
int i, j, loop, num_threads, iret;
float real_time, proc_time, mflops;
long long flpops;

	my_id=0;
	npes=1;
#ifdef _OPENMP
	num_threads  = omp_get_max_threads();
#else
	num_threads  = 1;
#endif
	if(my_id == 0) fprintf(stderr, "<main> starting STREAM test\n");

	PM.initialize();

/* The following block of Power API tests may not be welcomed :-P */
/*
	for (int i=0; i<Max_power_knob ; i++)
	{
		iknob=i;
		PM.getPowerKnob(iknob, value);
		if(my_id == 0) fprintf(stderr, "preset value of power knob %d is %d \n", iknob, value);
	}

	for (int i=0; i<Max_power_knob ; i++)
	{
		if(my_id == 0) fprintf(stderr, "set the new value of power knob %d is %d \n", iknob, value);
		iknob=i;
		value=1;
		if(i == 0) value=2200;
		if(i == 1) value=9;
		PM.setPowerKnob(iknob, value);
	}
 */

	PM.start("stream_check");
	stream();
	PM.stop ("stream_check");

	//	PM.report(stderr);
	PM.report("");

	if(my_id == 0) fprintf(stderr, "calling <MPI_Finalize> \n");
	if(my_id == 0) fprintf(stderr, "<main> finished\n");
return 0;
}

