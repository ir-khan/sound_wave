import 'dart:developer';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sound_wave/src/features/waves/presentations/providers/audio_progress_provider.dart';
import 'package:sound_wave/src/features/waves/presentations/providers/play_pause_provider.dart';

part 'audio_player_controller.g.dart';

@riverpod
class AudioPlayerController extends _$AudioPlayerController {
  final _soLoud = SoLoud.instance;
  AudioSource? _audioSource;
  SoundHandle? _handle;

  @override
  SoLoud build() {
    _init();
    ref.onDispose(() {
      _dispose();
    });
    return _soLoud;
  }

  Future<void> _init() async {
    try {
      await _soLoud.init();
      _soLoud.setVisualizationEnabled(true);
    } catch (e) {
      log('AudioPlayer init error: $e');
    }
  }

  Future<void> _dispose() async {
    await _soLoud.disposeAllSources();
    _soLoud.deinit();
  }

  Future<void> disposeAllSources() async {
    try {
      await _soLoud.disposeAllSources();
    } catch (e) {
      log('AudioPlayer disposeAllSources error: $e');
    }
  }

  Future<void> play(String sourcePath) async {
    try {
      await _soLoud.disposeAllSources();
      _audioSource = await _soLoud.loadFile(sourcePath);
      _handle = await _soLoud.play(_audioSource!);
      ref.read(playPauseProvider.notifier).setValue(true);
      ref
          .read(audioProgressProvider.notifier)
          .startTracking(
            soLoud: _soLoud,
            handle: _handle!,
            duration: _soLoud.getLength(_audioSource!),
          );
    } on SoLoudNotInitializedException catch (e) {
      log('AudioPlayer play error: $e');
    }
  }

  void togglePlayPause() {
    if (_handle == null) return;
    _soLoud.pauseSwitch(_handle!);
    ref.read(playPauseProvider.notifier).toggle();
  }

  void seekAudio({required bool isForward}) {
    if (_handle == null || _audioSource == null) return;
    final currentPosition = _soLoud.getPosition(_handle!);
    final maxDuration = _soLoud.getLength(_audioSource!);
    final seek = Duration(seconds: isForward ? 5 : -5);
    var target = currentPosition + seek;
    if (!isForward && target <= Duration.zero) {
      target = Duration.zero;
    } else if (isForward && target >= maxDuration) {
      target = maxDuration;
    }
    _soLoud.seek(_handle!, target);
  }

  void seekToSeconds(int seconds) {
    if (_handle == null) return;
    _soLoud.seek(_handle!, Duration(seconds: seconds));
  }

  Future<void> onButtonClickPlay() async {
    try {
      await _soLoud.play(await _soLoud.loadAsset('assets/sounds/sound1.wav'));
    } catch (e) {
      log('Click Sound: $e');
    }
  }
}
