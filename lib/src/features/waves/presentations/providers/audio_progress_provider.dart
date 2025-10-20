import 'dart:async';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sound_wave/src/features/waves/presentations/providers/play_pause_provider.dart';

part 'audio_progress_provider.g.dart';

@riverpod
class AudioProgress extends _$AudioProgress {
  Timer? _timer;
  Duration _duration = Duration.zero;

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
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (state.inSeconds >= duration.inSeconds) {
        ref.read(playPauseProvider.notifier).setValue(false);
      }
      final position = soLoud.getPosition(handle);
      state = position;
    });
  }
}
