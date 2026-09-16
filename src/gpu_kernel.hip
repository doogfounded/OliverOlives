// gpu_kernel.hip
#include <iostream>

#if defined(__HIP_PLATFORM_AMD__) || defined(__HIPCC__)
  #include <hip/hip_runtime.h>
  #define gpuSuccess hipSuccess
  #define gpuMalloc hipMalloc
  #define gpuMemcpy hipMemcpy
  #define gpuMemcpyHostToDevice hipMemcpyHostToDevice
  #define gpuMemcpyDeviceToHost hipMemcpyDeviceToHost
  #define gpuFree hipFree
#else
  #include <cuda_runtime.h>
  #define gpuSuccess cudaSuccess
  #define gpuMalloc cudaMalloc
  #define gpuMemcpy cudaMemcpy
  #define gpuMemcpyHostToDevice cudaMemcpyHostToDevice
  #define gpuMemcpyDeviceToHost cudaMemcpyDeviceToHost
  #define gpuFree cudaFree
#endif

__global__ void xor_kernel(uint32_t* d_data, size_t count) {
    size_t idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < count) {
        d_data[idx] = (d_data[idx] ^ 0xCAFEBABE) + 1;
    }
}

extern "C" void run_gpu_compute(uint32_t* host_data, size_t count) {
    uint32_t* d_data = nullptr;
    size_t bytes = count * sizeof(uint32_t);

    if (gpuMalloc(&d_data, bytes) != gpuSuccess) {
        std::cerr << "[GPU] Allocation failed! Falling back.\n";
        return;
    }

    gpuMemcpy(d_data, host_data, bytes, gpuMemcpyHostToDevice);

    int threads = 256;
    int blocks = (count + threads - 1) / threads;
    xor_kernel<<<blocks, threads>>>(d_data, count);

    gpuMemcpy(host_data, d_data, bytes, gpuMemcpyDeviceToHost);
    gpuFree(d_data);

    std::cout << "[GPU] Kernel dispatched and completed on AMD device.\n";
}