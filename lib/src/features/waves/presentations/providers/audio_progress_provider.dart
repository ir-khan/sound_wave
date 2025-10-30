import 'dart:async';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_progress_provider.g.dart';

@riverpod
class AudioProgress extends _$AudioProgress {
  Timer? _timer;
  Duration _duration = Duration.zero;
  bool playNext = false;

  Duration get duration => _duration;

  @override
  Duration build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return Duration.zero;
  }

  void startTracking({
    required SoLoud soLoud,
    required SoundHandle handle,
    required Duration duration,
  }) {
    _duration = duration;

    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (state.inSeconds == duration.inSeconds - 1) {
        playNext = true;
      }
      if (!soLoud.getIsValidVoiceHandle(handle)) {
        _timer?.cancel();
        soLoud.stop(handle);
      }
      final position = soLoud.getPosition(handle);
      state = position;
    });
  }
}
