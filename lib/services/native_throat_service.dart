import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

class NativeThroatService {
  late final DynamicLibrary _dylib;

  late final Pointer<Utf8> Function() _helloWorld;
  late final int Function(int, int) _add;
  late final int Function(Pointer<Utf8>) _startRecording;
  late final void Function() _stopRecording;

  NativeThroatService() {
    if (Platform.isWindows) {
      _dylib = DynamicLibrary.open('runner.exe');
    } else {
      // Add other platforms as needed
      throw UnsupportedError('Unsupported platform');
    }

    _helloWorld = _dylib
        .lookup<NativeFunction<Pointer<Utf8> Function()>>('hello_world')
        .asFunction();

    _add = _dylib
        .lookup<NativeFunction<Int32 Function(Int32, Int32)>>('add')
        .asFunction();

    _startRecording = _dylib
        .lookup<NativeFunction<Int32 Function(Pointer<Utf8>)>>('start_recording')
        .asFunction();

    _stopRecording = _dylib
        .lookup<NativeFunction<Void Function()>>('stop_recording')
        .asFunction();
  }

  String helloWorld() {
    return _helloWorld().toDartString();
  }

  int add(int a, int b) {
    return _add(a, b);
  }

  int startRecording(String path) {
    final cPath = path.toNativeUtf8();
    final result = _startRecording(cPath);
    malloc.free(cPath);
    return result;
  }

  void stopRecording() {
    _stopRecording();
  }
}
