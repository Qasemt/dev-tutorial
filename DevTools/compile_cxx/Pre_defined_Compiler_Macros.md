### Pre-defined Compiler Macros
__________
```bash
#ifdef __MINGW32__

x86_64-w64-mingw32-gcc defines both __MINGW32__ and __MINGW64__.


#if defined(__MINGW64__)
#define WTF_COMPILER_MINGW64 1
#endif
Pre_defined_Compiler_Macros

Visual Studio       _MSC_VER
gcc                 __GNUC__
clang               __clang__
emscripten          __EMSCRIPTEN__ (for asm.js and webassembly)
MinGW 32            __MINGW32__
MinGW-w64 32bit     __MINGW32__
MinGW-w64 64bit     __MINGW64__

/////////////////

Linux and Linux-derived           __linux__
Android                           __ANDROID__ (implies __linux__)
Linux (non-Android)               __linux__ && !__ANDROID__
Darwin (Mac OS X and iOS)         __APPLE__
Akaros (http://akaros.org)        __ros__
Windows                           _WIN32
Windows 64 bit                    _WIN64 (implies _WIN32)
NaCL                              __native_client__
AsmJS                             __asmjs__
Fuschia                           __Fuchsia__

```
