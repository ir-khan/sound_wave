import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/audio_progress_provider.dart';

class AudioProgressBar extends ConsumerWidget {
  const AudioProgressBar({super.key, required this.onChanged});

  final void Function(double)? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(audioProgressProvider);
    final notifier = ref.read(audioProgressProvider.notifier);
    final duration = notifier.duration;

    return Row(
      children: [
        /// TODO ( Izn ur Rehman ) : Make it explainable also If the Audio is more than 1 hour then we will have an issue here
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Text(position.toString().substring(2, 7)),
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
        /// TODO ( Izn ur Rehman ) : Make it explainable also If the Audio is more than 1 hour then we will have an issue here
        Padding(
          padding: const EdgeInsets.only(right: 5.0),
          child: Text(duration.toString().substring(2, 7)),
        ),
      ],
    );
  }
}
