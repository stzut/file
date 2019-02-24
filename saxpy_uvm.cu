#include <stdio.h>

#include <cuda.h>
#include <cuda_runtime.h>
#include <driver_functions.h>

#include "CycleTimer.h"
#include "saxpy.h"

__global__ void
saxpy_kernel(int N, float alpha, float* x, float* y, float* result) {

    // compute overall index from position of thread in current block,
    // and given the block we are in
    int index = blockIdx.x * blockDim.x + threadIdx.x;

    if (index < N)
       result[index] = alpha * x[index] + y[index];
}

static inline
int getBlocks(long working_set_size, int threadsPerBlock) {
  // TODO: implement and use this interface if necessary
    int Block_num = (working_set_size + threadsPerBlock -1) / threadsPerBlock;
    return Block_num;  
}

void 
getArrays(int size, float **xarray, float **yarray, float **resultarray) {
  // TODO: implement and use this interface if necessary 
  // we will not use it 
}

void 
freeArrays(float *xarray, float *yarray, float *resultarray) {
  // TODO: implement and use this interface if necessary 
    cudaFree(xarray);
    cudaFree(yarray);
    cudaFree(resultarray); 
}

void
saxpyCuda(long total_elems, float alpha, float* xarray, float* yarray, float* resultarray, int partitions) {

    const int threadsPerBlock = 512; // change this if necessary

    float *device_x;
    float *device_y;
    float *device_result;

    //
    // TODO: do we need to allocate device memory buffers on the GPU here?
    //
    cudaMallocManaged(&device_x, total_elems*sizeof(float));
    cudaMallocManaged(&device_y, total_elems*sizeof(float));
    cudaMallocManaged(&device_result, total_elems*sizeof(float));
    // start timing after allocation of device memory.
    double startTime = CycleTimer::currentSeconds();

  
    //
    // TODO: do we need copy here?
    // No! because unified memory is acessible by both CPU and GPU
     
    //
    // TODO: insert time here to begin timing only the kernel
    //
    double startGPUTime = CycleTimer::currentSeconds();
    // compute number of blocks and threads per block
    int Block_num = getBlocks(total_elems, threadsPerBlock);
    // run saxpy_kernel on the GPU
    saxpy_kernel<<<Block_num, threadsPerBlock>>>(total_elems, alpha, device_x, device_y, device_result);
    //
    // TODO: insert timer here to time only the kernel.  Since the
    // kernel will run asynchronously with the calling CPU thread, you
    // need to call cudaDeviceSynchronize() before your timer to
    // ensure the kernel running on the GPU has completed.  (Otherwise
    // you will incorrectly observe that almost no time elapses!)
    //
    cudaDeviceSynchronize();
    double endGPUTime = CycleTimer::currentSeconds();
    double timeKernel = endGPUTime - startGPUTime;
    
    cudaError_t errCode = cudaPeekAtLastError();
    if (errCode != cudaSuccess) {
        fprintf(stderr, "WARNING: A CUDA error occured: code=%d, %s\n", errCode, cudaGetErrorString(errCode));
    }
    
    //
    // TODO: copy result from GPU using cudaMemcpy
    //
    double start_dev2host_Time = CycleTimer::currentSeconds();

    cudaMemcpy(resultarray, device_result, total_elems * sizeof(float), cudaMemcpyDeviceToHost);
    
    double end_dev2host_Time = CycleTimer::currentSeconds();
    double timedev2Host = end_dev2host_Time - start_dev2host_Time;

    // What would be copy time when we use UVM?
    double endTime = CycleTimer::currentSeconds();
    double overallDuration = endTime - startTime;
    totalTimeAvg   += overallDuration;
    timeKernelAvg  += timeKernel;
    timeCopyD2HAvg += timedev2Host;

    //
    // TODO free device memory if you allocate some device memory earlier in this function.
    //
    freeArrays(device_x, device_y, device_result);
}

void
printCudaInfo() {

    // for fun, just print out some stats on the machine

    int deviceCount = 0;
    cudaError_t err = cudaGetDeviceCount(&deviceCount);

    printf("---------------------------------------------------------\n");
    printf("Found %d CUDA devices\n", deviceCount);

    for (int i=0; i<deviceCount; i++) {
        cudaDeviceProp deviceProps;
        cudaGetDeviceProperties(&deviceProps, i);
        printf("Device %d: %s\n", i, deviceProps.name);
        printf("   SMs:        %d\n", deviceProps.multiProcessorCount);
        printf("   Global mem: %.0f MB\n",
               static_cast<float>(deviceProps.totalGlobalMem) / (1024 * 1024));
        printf("   CUDA Cap:   %d.%d\n", deviceProps.major, deviceProps.minor);
    }
    printf("---------------------------------------------------------\n");
}
