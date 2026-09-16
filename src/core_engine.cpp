// core_engine.cpp
#include "core_engine.h"
#include <numeric>

void ComputeEngine::process_buffer(uint32_t *data, size_t count) {
  for (size_t i = 0; i < count; ++i) {
    data[i] = (data[i] ^ 0x5A5A5A5A) + 1;
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