#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define M 512 
#define N 512 
#define P 512

void matmul(float **A, float **B, float **C) { 
	float sum;
	int i;
	int j;
	int k;
	for (i = 0; i<M; i++) { 
		for (j=0; j<N; j++) {
			sum = 0.0f; 
			for (k=0; k<P; k++) {
				sum += A[i][k]*B[k][j]; 
			}
				C[i][j] = sum; 
		}
	} 
}

void create_matrix(float*** A, int m, int n)
{
    float **T = 0;
    int i;
    T = (float**)malloc( m*sizeof(float*)); 
    for ( i=0; i<m; i++ ) {
		T[i] = (float*)malloc(n*sizeof(float)); 
	}
	*A=T; 
}


int main()
{
	float** A;
	float** B;
	float** C;
	create_matrix(&A, M, P);
	create_matrix(&B, P, N);
	create_matrix(&C, M, N);
	return 0;
}