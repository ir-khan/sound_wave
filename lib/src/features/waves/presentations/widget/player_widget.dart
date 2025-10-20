import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sound_wave/src/features/waves/presentations/providers/play_pause_provider.dart';

import '../../data/model/media.dart';
import 'audio_progress_bar.dart';
import 'icon_container.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({
    super.key,
    required this.media,
    required this.onTapSkipPrevious,
    required this.onTapSkipNext,
    required this.onSeekBackward,
    required this.onSeekForward,
    required this.onPlayPause,
    required this.onChanged,
  });

  final Media media;
  final void Function(Media) onTapSkipPrevious;
  final void Function(Media) onTapSkipNext;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;
  final VoidCallback onPlayPause;
  final void Function(double)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Text(media.name.toUpperCase()),
        AudioProgressBar(onChanged: onChanged),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 15,
          children: [
            IconContainer(
              icon: Icons.skip_previous_rounded,
              onPressed: () => onTapSkipPrevious(media),
            ),
            IconContainer(
              icon: Icons.replay_5_rounded,
              onPressed: onSeekBackward,
            ),
            Consumer(
              builder: (_, ref, _) {
                final playing = ref.watch(playPauseProvider);
                return IconContainer(
                  icon: playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  onPressed: onPlayPause,
                );
              },
            ),
            IconContainer(
              icon: Icons.forward_5_rounded,
              onPressed: onSeekForward,
            ),
            IconContainer(
              icon: Icons.skip_next_rounded,
              onPressed: () => onTapSkipNext(media),
            ),
          ],
        ),
      ],
    );
  }
}
