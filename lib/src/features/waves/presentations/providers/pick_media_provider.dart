import 'package:cross_file/cross_file.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sound_wave/src/core/services/media_service.dart';

part 'pick_media_provider.g.dart';

@riverpod
Future<List<XFile>> pickMedia(Ref ref) async {
  return await ref.watch(mediaServiceProvider).pickMedia();
}
