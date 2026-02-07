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

    // Recording
    DLLEXPORT int start_recording(const char* path);
    DLLEXPORT void stop_recording();

    // Playback
    DLLEXPORT int start_playing(const char* path);
    DLLEXPORT void stop_playing();
    DLLEXPORT bool is_playing_query();
}

#endif // NATIVE_THROAT_H
