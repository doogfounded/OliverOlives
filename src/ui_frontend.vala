// ui_frontend.vala
using GLib;

// Directly import the C entrypoints exposed by C++ and Objective-C++
[CCode (cname = "run_objective_cxx_pipeline")]
extern void run_objective_cxx_pipeline();

[CCode (cname = "engine_create")]
extern void* engine_create();

[CCode (cname = "engine_get_checksum")]
extern uint32 engine_get_checksum(void* handle);

[CCode (cname = "engine_destroy")]
extern void engine_destroy(void* handle);

public class Controller : Object {
    public void execute() {
        print("[Vala] Starting multi-language pipeline...\n");

        // 1. Call into the Objective-C++ subsystem
        print("[Vala] Invoking Objective-C++ layer...\n");
        run_objective_cxx_pipeline();

        // 2. Interact directly with the C++ core via C ABI trampolines
        print("[Vala] Allocating raw C++ engine directly...\n");
        void* engine = engine_create();
        
        uint32 initial_sum = engine_get_checksum(engine);
        print(@"[Vala] Initial core checksum: 0x$initial_sum\n");

        engine_destroy(engine);
        print("[Vala] Teardown complete.\n");
    }
}

int main(string[] args) {
    var app = new Controller();
    app.execute();
    return 0;
}