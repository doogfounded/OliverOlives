// apple_bridge.mm
#import "apple_bridge.h"
#include "core_engine.h"
#include <iostream>
#include <vector>

@implementation EngineSession {
  // Objective-C ivar storing a native C++ object directly
  ComputeEngine _engine;
}

- (instancetype)init {
  self = [super init];
  return self;
}

- (void)runBatch:(uint32_t)size {
  std::vector<uint32_t> buffer(size, 0x12345678);
  _engine.process_buffer(buffer.data(), buffer.size());
}

- (NSString *)diagnosticSummary {
  uint32_t sum = _engine.get_checksum();
  return [NSString stringWithFormat:@"Engine Checksum: 0x%08X", sum];
}

@end

// C wrapper so Vala can trigger Objective-C message sends
void run_objective_cxx_pipeline(void) {
  @autoreleasepool {
    EngineSession *session = [[EngineSession alloc] init];
    [session runBatch:1024];

    NSString *report = [session diagnosticSummary];
    std::cout << "[ObjC++] " << [report UTF8String] << std::endl;
  }
}