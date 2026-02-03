#include <jni.h>
#include <android/log.h>

// Simple audio processing example in C++
// In a real app, you might use Oboe or OpenSL ES here

extern "C" JNIEXPORT jstring JNICALL
Java_com_synapse_twospace_MainActivity_stringFromJNI(
        JNIEnv* env,
        jobject /* this */) {
    return env->NewStringUTF("Hello from C++ Audio Engine");
}

extern "C" JNIEXPORT void JNICALL
Java_com_synapse_twospace_MainActivity_processAudio(
        JNIEnv* env,
        jobject /* this */,
        jfloatArray audioData) {

    // Example: Process audio data (e.g., apply gain)
    jfloat* data = env->GetFloatArrayElements(audioData, 0);
    jsize length = env->GetArrayLength(audioData);

    for (int i = 0; i < length; i++) {
        data[i] = data[i] * 0.5f; // Reduce volume by half
    }

    env->ReleaseFloatArrayElements(audioData, data, 0);
}
