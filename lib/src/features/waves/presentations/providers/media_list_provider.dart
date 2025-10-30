import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sound_wave/src/features/waves/data/model/media.dart';

import '../../../../core/services/media_service.dart';

part 'media_list_provider.g.dart';

@riverpod
class MediaList extends _$MediaList {
  @override
  List<Media> build() {
    return [];
  }

  void pickMedia() async {
    final newState = await ref.read(mediaServiceProvider).pickMedia();
    state = [
      ...state,
      ...newState.map((media) => Media(name: media.name, path: media.path)),
    ];
  }
}
