import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sound_wave/src/extensions/duration.dart';

import '../providers/audio_progress_provider.dart';
import '../providers/play_pause_provider.dart';

class AudioProgressBar extends ConsumerWidget {
  const AudioProgressBar({
    super.key,
    required this.onChanged,
    required this.onComplete,
  });

  final void Function(double)? onChanged;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(audioProgressProvider);
    final notifier = ref.read(audioProgressProvider.notifier);
    final duration = notifier.duration;

    ref.listen(audioProgressProvider, (previous, next) {
      if (notifier.playNext && next.inSeconds == duration.inSeconds) {
        ref.read(playPauseProvider.notifier).setValue(false);
        onComplete();
      }
    });

    return Row(
      children: [
        /// ✅ TODO ( Izn ur Rehman ) : Make it explainable also If the Audio is more than 1 hour then we will have an issue here
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Text(position.format()),
        ),
        Expanded(
          child: Slider(
            value: position.inSeconds.toDouble(),
            max: duration.inSeconds.toDouble(),
            onChanged: onChanged,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            allowedInteraction: SliderInteraction.slideThumb,
          ),
        ),

        /// ✅ TODO ( Izn ur Rehman ) : Make it explainable also If the Audio is more than 1 hour then we will have an issue here
        Padding(
          padding: const EdgeInsets.only(right: 5.0),
          child: Text(duration.format()),
        ),
      ],
    );
  }
}
