import 'dart:io';

import 'package:audio_flux/audio_flux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sound_wave/src/features/waves/presentations/providers/audio_player_controller.dart';
import 'package:sound_wave/src/features/waves/presentations/providers/audio_recording_controller.dart';
import 'package:sound_wave/src/features/waves/presentations/providers/media_list_provider.dart';
import 'package:sound_wave/src/features/waves/presentations/widget/icon_container.dart';

import '../../../mixins/media_query_mixin.dart';
import '../data/model/media.dart';
import 'widget/player_widget.dart';

class SelectMediaPage extends ConsumerStatefulWidget {
  const SelectMediaPage({super.key});

  @override
  ConsumerState<SelectMediaPage> createState() => _SelectMediaPageState();
}

class _SelectMediaPageState extends ConsumerState<SelectMediaPage>
    with MediaQueryMixin {
  Media? _selectedMedia;

  @override
  Widget build(BuildContext context) {
    final audioPlayerController = ref.read(
      audioPlayerControllerProvider.notifier,
    );
    final audioRecordingController = ref.read(
      audioRecordingControllerProvider.notifier,
    );
    final media = ref.watch(mediaListProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Music Player')),
      body: Column(
        spacing: 10,
        children: [
          if (_selectedMedia != null)
            Column(
              children: [
                /// ✅ TODO ( Izn ur Rehman ) : The Audio Flux is not Displaying
                SizedBox(
                  width: size.width,
                  height: size.height * 0.35,
                  child: AudioFlux(
                    dataSource: DataSources.soloud,
                    fluxType: FluxType.waveform,
                    modelParams: ModelParams(
                      audioScale: 0.55,
                      backgroundColor: Colors.transparent,
                      barColor: Colors.red,
                      waveformParams: WaveformPainterParams(
                        barsWidth: 2,
                        barSpacingScale: 0.55,
                        barRadius: 0,
                      ),
                    ),
                  ),
                ),
                PlayerWidget(
                  media: _selectedMedia!,
                  onTapSkipPrevious: (value) {
                    /// ✅ TODO ( Izn ur Rehman ) : If I started a single file and click on previous button the audio is not getting restarted
                    audioPlayerController.onButtonClickPlay();
                    final index = media.indexOf(value);
                    if (index == 0) {
                      _selectedMedia = media[media.length - 1];
                    } else {
                      _selectedMedia = media[index - 1];
                    }

                    audioPlayerController.play(_selectedMedia!.path);
                    if (!mounted) return;
                    setState(() {});
                  },
                  onTapSkipNext: (value) {
                    audioPlayerController.onButtonClickPlay();
                    final index = media.indexOf(value);
                    if (index == media.length - 1) {
                      _selectedMedia = media[0];
                    } else {
                      _selectedMedia = media[index + 1];
                    }
                    audioPlayerController.play(_selectedMedia!.path);
                    if (!mounted) return;
                    setState(() {});
                  },
                  onPlayPause: () {
                    audioPlayerController.onButtonClickPlay();
                    audioPlayerController.togglePlayPause();
                  },
                  onSeekBackward: () {
                    audioPlayerController.onButtonClickPlay();
                    audioPlayerController.seekAudio(isForward: false);
                  },
                  onSeekForward: () {
                    audioPlayerController.onButtonClickPlay();
                    audioPlayerController.seekAudio(isForward: true);
                  },
                  onChanged: (value) =>
                      audioPlayerController.seekToSeconds(value.toInt()),
                  onComplete: () {
                    final index = media.indexOf(_selectedMedia!);
                    if (index == media.length - 1) {
                      _selectedMedia = media[0];
                    } else {
                      _selectedMedia = media[index + 1];
                    }
                    audioPlayerController.play(_selectedMedia!.path);
                    if (!mounted) return;
                    setState(() {});
                  },
                ),
              ],
            ),
          if (media.isEmpty)
            /// ✅ TODO ( Izn ur Rehman ) : Optimize this widget tree
            Text(
              'Please select media from your device.',
              textAlign: TextAlign.center,
            ),
          ElevatedButton(
            onPressed: () async {
              audioPlayerController.onButtonClickPlay();
              await HapticFeedback.vibrate();
              ref.read(mediaListProvider.notifier).pickMedia();
            },
            child: Text('Select Audio'),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 20,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    audioPlayerController.onButtonClickPlay();
                    await HapticFeedback.vibrate();
                    await audioPlayerController.disposeAllSources();
                    await audioRecordingController.recordUserAudio();
                  },
                  child: Text('Record Audio'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    audioPlayerController.onButtonClickPlay();
                    await HapticFeedback.vibrate();
                    await audioRecordingController.stopRecordingAudio();
                  },
                  child: Text('Stop Recording'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    audioPlayerController.onButtonClickPlay();
                    await HapticFeedback.vibrate();
                    final filePath = audioRecordingController.getFilePath();
                    if (filePath == null) return;
                    _selectedMedia = Media(
                      name: filePath.split(Platform.pathSeparator).last,
                      path: filePath,
                    );
                    if (!mounted) return;
                    setState(() {});
                    audioPlayerController.play(filePath);
                  },
                  child: Text('Play Audio'),
                ),
              ],
            ),
          ),
          if (media.isNotEmpty)
            Expanded(
              child: ListView.separated(
                itemBuilder: (_, index) {
                  final med = media[index];
                  return ListTile(
                    selected: _selectedMedia == med,
                    selectedColor: Colors.red,
                    onTap: () async {
                      /// ✅ TODO ( Izn ur Rehman ) : The audio is not getting played when I tapped on a selected file
                      /// It gives me this error : SoLoudFileLoadFailedException: File found, but could not be loaded! Could be a permission error or the file is corrupted. (on the C++ side).
                      await HapticFeedback.vibrate();
                      audioPlayerController.onButtonClickPlay();
                      _selectedMedia = med;
                      if (_selectedMedia == null) return;
                      audioPlayerController.play(_selectedMedia!.path);
                      if (!mounted) return;
                      setState(() {});
                    },
                    leading: IconContainer(
                      icon: Icons.play_arrow_rounded,
                      onPressed: () {},
                    ),
                    title: Text(med.name),
                  );
                },
                separatorBuilder: (_, _) => SizedBox(height: 10),
                itemCount: media.length,
              ),
            ),
        ],
      ),
    );
  }
}

/// ✅ TODO ( Izn ur Rehman ) : It does not auto play the second audio after completion of First video
/// ✅ TODO ( Izn ur Rehman ) : The Audio is Finished but the Play Pause icon is still indicates that audio is still playing
/// ✅ TODO ( Izn ur Rehman ) : Create a provider that will responsible for Recording
/// ✅ TODO ( Izn ur Rehman ) : Create a Provider That will responsible for Playing Audio and all it's functionalities
///
