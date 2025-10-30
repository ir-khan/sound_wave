import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_recording_controller.g.dart';

@riverpod
class AudioRecordingController extends _$AudioRecordingController {
  final _recorder = Recorder.instance;
  String? _recordedFilePath;

  @override
  Recorder build() {
    _init();
    ref.onDispose(() {
      _dispose();
    });
    return _recorder;
  }

  Future<void> _init() async {
    try {
      await _recorder.init(
        sampleRate: 44100,
        format: PCMFormat.f32le,
        channels: RecorderChannels.mono,
      );
    } catch (e) {
      log('Recorder init error: $e');
    }
  }

  Future<void> _dispose() async {
    _recorder.deinit();
  }

  Future<void> recordUserAudio() async {
    try {
      final granted = await _getMicrophonePermission();
      if (!granted) return;
      _recordedFilePath =
          '${await _getPathToStorage()}${Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch}';
      _recorder.start();
      _recorder.startRecording(completeFilePath: _recordedFilePath!);
    } catch (e) {
      log('Record Audio: $e');
    }
  }

  Future<void> stopRecordingAudio() async {
    try {
      _recorder.stopRecording();
      _recorder.stop();
    } catch (e) {
      log('Stop Recording Audio: $e');
    }
  }

  Future<void> playAudio() async {
    try {} catch (e) {
      log('Play Audio: $e');
    }
  }

  String? getFilePath() {
    return _recordedFilePath;
  }
}

Future<bool> _getMicrophonePermission() async {
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    final value = await Permission.microphone.request().isGranted;
    if (value) return true;
    final permission = await Permission.microphone.request();
    return permission.isGranted;
  }
  return false;
}

Future<String> _getPathToStorage() async {
  final tempDir = await getTemporaryDirectory();
  return tempDir.path;
}
