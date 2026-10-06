#include <hxcpp.h>

#ifdef __WIIU__
#include <wut.h>
#include <proc_ui/procui.h>
#include <hxcpp.h>
#include <hx/Boot.h>
#include <cstdio>
#include <cstdlib>

extern "C" void __hxcpp_main();
extern "C" void __hxcpp_lib_main();

extern int _hxcpp_argc;
extern char **_hxcpp_argv;

#include <malloc.h>
#include <sys/socket.h>

void __hxcpp_exit(int status) {
    std::exit(status);
}

static void SaveCallback() {
}

extern "C" int main(int argc, char **argv) {
    ProcUIInit(SaveCallback);
    hx::Boot();
    
    int exitCode = EXIT_SUCCESS;
    
    try {
        __hxcpp_main();
    } catch (Dynamic d) {
        printf("[EXCEPTION OCCURRED!]\n%s\n\n", String(d).c_str());
        __hx_dump_stack();
        exitCode = EXIT_FAILURE;
    }
    
    ProcUIShutdown();
    
    return exitCode;
}
#endif
