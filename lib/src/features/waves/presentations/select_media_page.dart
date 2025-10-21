import 'dart:developer';
import 'dart:io';

import 'package:audio_flux/audio_flux.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_wave/src/features/waves/presentations/providers/audio_progress_provider.dart';
import 'package:sound_wave/src/features/waves/presentations/providers/media_list_provider.dart';
import 'package:sound_wave/src/features/waves/presentations/providers/play_pause_provider.dart';
import 'package:sound_wave/src/features/waves/presentations/widget/icon_container.dart';
import 'package:sound_wave/src/mixins/media_query_mixin.dart';

import '../data/model/media.dart';
import 'widget/player_widget.dart';

class SelectMediaPage extends ConsumerStatefulWidget {
  const SelectMediaPage({super.key});

  @override
  ConsumerState<SelectMediaPage> createState() => _SelectMediaPageState();
}

class _SelectMediaPageState extends ConsumerState<SelectMediaPage>
    with MediaQueryMixin {
  final _soLoud = SoLoud.instance;
  final _recorder = Recorder.instance;
  final _dataSource = ValueNotifier(DataSources.soloud);
  Media? _selectedMedia;
  AudioSource? _audioSource;
  SoundHandle? _handle;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _soLoud.init(bufferSize: 1024, channels: Channels.stereo);
    _soLoud.setVisualizationEnabled(true);
    await _recorder.init(
      sampleRate: 44100,
      format: PCMFormat.f32le,
      channels: RecorderChannels.mono,
    );
  }

  Future<void> _play(String sourcePath) async {
    try {
      await _soLoud.disposeAllSources();
      _audioSource = await _soLoud.loadFile(sourcePath, mode: LoadMode.memory);
      _handle = await _soLoud.play(_audioSource!);
    } on SoLoudNotInitializedException catch (e) {
      log(e.toString());
    }
    ref.read(playPauseProvider.notifier).setValue(true);
    ref
        .read(audioProgressProvider.notifier)
        .startTracking(
          soLoud: _soLoud,
          handle: _handle!,
          duration: _soLoud.getLength(_audioSource!),
        );
  }

  Future<void> _recordUserAudio() async {
    try {
      _soLoud.disposeAllSources();
      final granted = await _getMicrophonePermission();
      if (!granted) return;
      _recordedFilePath =
          '${await _getPathToStorage()}${Platform.pathSeparator}${DateTime.now().millisecond}';
      _recorder.start();
      _recorder.startRecording(completeFilePath: _recordedFilePath!);
    } catch (e) {
      log('Record Audio: $e');
    }
  }

  Future<void> _onButtonClickPlay() async {
    await _soLoud.play(await _soLoud.loadAsset('assets/sounds/sound1.wav'));
  }

  void _seekAudio({required isForward}) {
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

  @override
  void dispose() {
    if (_handle != null) {
      _soLoud.stop(_handle!);
    }
    if (_audioSource != null) {
      _soLoud.disposeSource(_audioSource!);
    }
    _soLoud.disposeAllSources();
    _soLoud.deinit();
    _recorder.deinit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = ref.watch(mediaListProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Music Player')),
      body: Column(
        spacing: 10,
        children: [
          if (_selectedMedia != null)
            Column(
              children: [
                SizedBox(
                  height: size.height * 0.35,
                  child: ValueListenableBuilder(
                    valueListenable: _dataSource,
                    builder: (_, value, _) {
                      return AudioFlux(
                        dataSource: value,
                        fluxType: FluxType.waveform,
                        modelParams: ModelParams(
                          audioScale: 1,
                          backgroundColor: Colors.blueGrey,
                          barColor: Colors.white70,
                          waveformParams: WaveformPainterParams(),
                          shaderParams: ShaderParams(
                            shaderName: 'Frequency Visualization',
                            shaderPath:
                                'assets/shaders/frequency_visualization.frag',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                PlayerWidget(
                  media: _selectedMedia!,
                  onTapSkipPrevious: (value) {
                    _onButtonClickPlay();
                    final index = media.indexOf(value);
                    if (index == 0) return;
                    _selectedMedia = media[index - 1];
                    _play(_selectedMedia!.path);
                    if (!mounted) return;
                    setState(() {});
                  },
                  onTapSkipNext: (value) {
                    _onButtonClickPlay();
                    final index = media.indexOf(value);
                    if (index == media.length - 1) return;
                    _selectedMedia = media[index + 1];
                    _play(_selectedMedia!.path);
                    if (!mounted) return;
                    setState(() {});
                  },
                  onPlayPause: () async {
                    _onButtonClickPlay();
                    ref
                        .read(playPauseProvider.notifier)
                        .setValue(!ref.read(playPauseProvider));
                    _soLoud.pauseSwitch(_handle!);
                  },
                  onSeekBackward: () {
                    _onButtonClickPlay();
                    _seekAudio(isForward: false);
                  },
                  onSeekForward: () {
                    _onButtonClickPlay();
                    _seekAudio(isForward: true);
                  },
                  onChanged: (value) =>
                      _soLoud.seek(_handle!, Duration(seconds: value.toInt())),
                ),
              ],
            ),
          if (media.isEmpty)
            SizedBox(
              width: size.width,
              child: Text(
                'Please select media from your device.',
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: () async {
              _onButtonClickPlay();
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
                    _onButtonClickPlay();
                    await HapticFeedback.vibrate();
                    await _recordUserAudio();
                  },
                  child: Text('Record Audio'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    _onButtonClickPlay();
                    await HapticFeedback.vibrate();
                    _recorder.stopRecording();
                    _recorder.stop();
                  },
                  child: Text('Stop Recording'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    _onButtonClickPlay();
                    await HapticFeedback.vibrate();
                    if (_recordedFilePath == null) return;
                    _selectedMedia = Media(
                      name: _recordedFilePath!
                          .split(Platform.pathSeparator)
                          .last,
                      path: _recordedFilePath!,
                    );
                    _dataSource.value = DataSources.recorder;
                    await _play(_recordedFilePath!);
                    if (!mounted) return;
                    setState(() {});
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
                      await HapticFeedback.vibrate();
                      _onButtonClickPlay();
                      _selectedMedia = med;
                      if (_selectedMedia == null) return;
                      _play(_selectedMedia!.path);
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
