// apple_bridge.h
#import <Foundation/Foundation.h>
#include <stdint.h>

@interface EngineSession : NSObject

- (instancetype)init;
- (void)runBatch:(uint32_t)size;
- (NSString *)diagnosticSummary;

@end

#ifdef __cplusplus
extern "C" {
#endif

// Exported C entrypoint for Vala/GLib to call into the ObjC runtime
void run_objective_cxx_pipeline(void);

#ifdef __cplusplus
}
#endif