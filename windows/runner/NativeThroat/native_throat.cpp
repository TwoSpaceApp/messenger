#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"
#include "native_throat.h"
#include <stdio.h>
#include <vorbis/vorbisenc.h>

static ma_device recording_device;
static bool is_recording = false;

static ma_device playback_device;
static bool is_playing = false;

// Ogg Vorbis recording state
static ogg_stream_state os;
static ogg_page         og;
static ogg_packet       op;
static vorbis_info      vi;
static vorbis_comment   vc;
static vorbis_dsp_state vd;
static vorbis_block     vb;
static FILE*            ogg_file = nullptr;

void data_callback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount)
{
    if (is_recording && ogg_file) {
        float** buffer = vorbis_analysis_buffer(&vd, frameCount);
        const float* in = (const float*)pInput;

        for (ma_uint32 i = 0; i < frameCount; i++) {
            buffer[0][i] = in[i * 2];
            buffer[1][i] = in[i * 2 + 1];
        }

        vorbis_analysis_wrote(&vd, frameCount);

        while (vorbis_analysis_blockout(&vd, &vb) == 1) {
            vorbis_analysis(&vb, NULL);
            vorbis_bitrate_addblock(&vb);

            while (vorbis_bitrate_flushpacket(&vd, &op)) {
                ogg_stream_packetin(&os, &op);

                while (ogg_stream_pageout(&os, &og)) {
                    fwrite(og.header, 1, og.header_len, ogg_file);
                    fwrite(og.body, 1, og.body_len, ogg_file);
                }
            }
        }
    }
}

const char* hello_world() {
    return "Hello from NativeThroat!";
}

int add(int a, int b) {
    return a + b;
}

int start_recording(const char* path) {
    if (is_recording) {
        return -1; // Already recording
    }

    ogg_file = fopen(path, "wb");
    if (!ogg_file) {
        return -2; // Failed to open file
    }

    vorbis_info_init(&vi);
    int ret = vorbis_encode_init_vbr(&vi, 2, 48000, 0.4);
    if (ret) {
        fclose(ogg_file);
        return -3; // Failed to init vorbis encoder
    }

    vorbis_comment_init(&vc);
    vorbis_comment_add_tag(&vc, "ENCODER", "NativeThroat");

    vorbis_analysis_init(&vd, &vi);
    vorbis_block_init(&vd, &vb);

    srand(time(NULL));
    ogg_stream_init(&os, rand());

    ogg_packet header;
    ogg_packet header_comm;
    ogg_packet header_code;

    vorbis_analysis_headerout(&vd, &vc, &header, &header_comm, &header_code);
    ogg_stream_packetin(&os, &header);
    ogg_stream_packetin(&os, &header_comm);
    ogg_stream_packetin(&os, &header_code);

    while (ogg_stream_flush(&os, &og)) {
        fwrite(og.header, 1, og.header_len, ogg_file);
        fwrite(og.body, 1, og.body_len, ogg_file);
    }

    ma_device_config device_config = ma_device_config_init(ma_device_type_capture);
    device_config.capture.format   = ma_format_f32;
    device_config.capture.channels = 2;
    device_config.sampleRate       = 48000;
    device_config.dataCallback     = data_callback;

    if (ma_device_init(NULL, &device_config, &recording_device) != MA_SUCCESS) {
        fclose(ogg_file);
        return -4; // Failed to initialize recording device
    }

    if (ma_device_start(&recording_device) != MA_SUCCESS) {
        ma_device_uninit(&recording_device);
        fclose(ogg_file);
        return -5; // Failed to start recording device
    }

    is_recording = true;
    return 0; // Success
}

void stop_recording() {
    if (!is_recording) {
        return;
    }

    vorbis_analysis_wrote(&vd, 0);
    // ... (rest of the cleanup from the previous message)

    ma_device_uninit(&recording_device);

    if (ogg_file) {
        fclose(ogg_file);
        ogg_file = nullptr;
    }

    ogg_stream_clear(&os);
    vorbis_block_clear(&vb);
    vorbis_dsp_clear(&vd);
    vorbis_comment_clear(&vc);
    vorbis_info_clear(&vi);

    is_recording = false;
}

void playback_data_callback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount)
{
    ma_decoder* pDecoder = (ma_decoder*)pDevice->pUserData;
    if (pDecoder == NULL) {
        return;
    }

    ma_uint64 framesRead;
    ma_result result = ma_decoder_read_pcm_frames(pDecoder, pOutput, frameCount, &framesRead);
    if (result != MA_SUCCESS || framesRead == 0) {
        is_playing = false;
    }
}

int start_playing(const char* path) {
    if (is_playing) {
        stop_playing();
    }

    ma_decoder* pDecoder = (ma_decoder*)malloc(sizeof(ma_decoder));
    ma_result result = ma_decoder_init_file(path, NULL, pDecoder);
    if (result != MA_SUCCESS) {
        free(pDecoder);
        return -1;
    }

    ma_device_config deviceConfig = ma_device_config_init(ma_device_type_playback);
    deviceConfig.playback.format   = pDecoder->outputFormat;
    deviceConfig.playback.channels = pDecoder->outputChannels;
    deviceConfig.sampleRate        = pDecoder->outputSampleRate;
    deviceConfig.dataCallback      = playback_data_callback;
    deviceConfig.pUserData         = pDecoder;

    if (ma_device_init(NULL, &deviceConfig, &playback_device) != MA_SUCCESS) {
        ma_decoder_uninit(pDecoder);
        free(pDecoder);
        return -2;
    }

    if (ma_device_start(&playback_device) != MA_SUCCESS) {
        ma_device_uninit(&playback_device);
        ma_decoder_uninit(pDecoder);
        free(pDecoder);
        return -3;
    }

    is_playing = true;
    return 0;
}

void stop_playing() {
    if (!is_playing) {
        return;
    }

    ma_decoder* pDecoder = (ma_decoder*)playback_device.pUserData;
    ma_device_uninit(&playback_device);
    ma_decoder_uninit(pDecoder);
    free(pDecoder);
    is_playing = false;
}

bool is_playing_query() {
    return is_playing;
}
