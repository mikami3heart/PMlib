	
#include <stdio.h>
#include <unistd.h>
#include <stdbool.h>
#include <mpi.h>
#include <omp.h>

#define MATSIZE 10000
static struct matrix {
	int nsize;
	double a2[MATSIZE][MATSIZE];
	double b2[MATSIZE][MATSIZE];
	double c2[MATSIZE][MATSIZE];
} matrix;

void sub_initialize_();
void sub_dgemm_();

void sub_initialize_()
{
	int i, j, k, nsize;
	matrix.nsize = MATSIZE;
	nsize = matrix.nsize;
	#pragma omp parallel
	#pragma omp for
	for (i=0; i<nsize; i++){
		for (k=0; k<nsize; k++){
		matrix.a2[i][k] = 1.0;
		matrix.b2[i][k] = 2.0;
		matrix.c2[i][k] = 3.0;
		}
	}
	//	printf("<init_kernel> initializing %d x %d matrices\n", nsize, nsize);
}
	

void sub_dgemm_()
{
	int i, j, k, nsize;
	double c1,c2,c3,one=1.0;
	static char trans[]="N";
	//  static char trans[]="T";
	
	nsize = matrix.nsize;
	
		//	printf("<some_kernel> nsize=%d\n", nsize);
		//	#pragma omp parallel
		//	#pragma omp for
		for (i=0; i<nsize; i++){
		//	#pragma loop unroll
		for (j=0; j<nsize; j++){
			c1=2.0;
			for (k=0; k<nsize; k++){
			c2=matrix.a2[i][k] * matrix.a2[j][k];
			c3=matrix.b2[i][k] * matrix.b2[j][k];
			c1=c1 + c2+c3;
			}
			matrix.c2[i][j] = matrix.c2[i][j] + c1/(float)nsize;
		}
		}
}

