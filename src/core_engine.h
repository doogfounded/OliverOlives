// core_engine.h
#pragma once
#include <cstddef>
#include <cstdint>

class ComputeEngine {
public:
  ComputeEngine() = default;
  void process_buffer(uint32_t *data, size_t count);
  uint32_t get_checksum() const noexcept { return checksum_; }

private:
  uint32_t checksum_{0};
};

#ifdef __cplusplus
extern "C" {
#endif

void *engine_create();
void engine_process(void *handle, uint32_t *data, size_t count);
uint32_t engine_get_checksum(void *handle);
void engine_destroy(void *handle);

#ifdef __cplusplus
}
#endif