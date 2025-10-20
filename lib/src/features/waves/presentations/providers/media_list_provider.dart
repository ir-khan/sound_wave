import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sound_wave/src/features/waves/data/model/media.dart';
import 'package:sound_wave/src/features/waves/presentations/providers/pick_media_provider.dart';

part 'media_list_provider.g.dart';

@riverpod
class MediaList extends _$MediaList {
  @override
  List<Media> build() {
    return [];
  }

  void pickMedia() async {
    final newState = await ref.read(pickMediaProvider.future);
    state = [
      ...state,
      ...newState.map((media) => Media(name: media.name, path: media.path)),
    ];
  }
}
