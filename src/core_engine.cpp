// core_engine.cpp
#include "core_engine.h"
#include <numeric>

// Add to core_engine.cpp
extern "C" void run_gpu_compute(uint32_t *host_data, size_t count);

void ComputeEngine::process_buffer(uint32_t *data, size_t count) {
  // 1. Offload buffer processing to the GPU kernel
  run_gpu_compute(data, count);

  // 2. CPU checks final values
  for (size_t i = 0; i < count; ++i) {
    checksum_ += data[i];
  }
}
// C-Linkage trampoline functions
void *engine_create() { return static_cast<void *>(new ComputeEngine()); }

void engine_process(void *handle, uint32_t *data, size_t count) {
  if (handle) {
    static_cast<ComputeEngine *>(handle)->process_buffer(data, count);
  }
}

uint32_t engine_get_checksum(void *handle) {
  return handle ? static_cast<ComputeEngine *>(handle)->get_checksum() : 0;
}

void engine_destroy(void *handle) {
  delete static_cast<ComputeEngine *>(handle);
}