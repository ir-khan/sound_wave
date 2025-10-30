import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sound_wave/src/features/waves/presentations/providers/audio_player_controller.dart';
import 'package:sound_wave/src/features/waves/presentations/providers/audio_recording_controller.dart';

part 'app_startup_provider.g.dart';

@Riverpod(keepAlive: true)
Future<void> appStartup(Ref ref) async {
  ref.watch(audioPlayerControllerProvider);
  ref.watch(audioRecordingControllerProvider);
}
