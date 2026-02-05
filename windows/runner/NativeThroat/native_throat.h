#ifndef NATIVE_THROAT_H
#define NATIVE_THROAT_H

#ifdef _WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT
#endif

extern "C" {
    DLLEXPORT const char* hello_world();
    DLLEXPORT int add(int a, int b);
    DLLEXPORT int start_recording(const char* path);
    DLLEXPORT void stop_recording();
}

#endif // NATIVE_THROAT_H
