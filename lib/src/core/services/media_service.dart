import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cross_file/cross_file.dart';

part 'media_service.g.dart';

class MediaService {
  Future<List<XFile>> pickMedia() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result == null) return [];
      return result.xFiles;
    } catch (e) {
      rethrow;
    }
  }
}

@riverpod
MediaService mediaService(Ref _) {
  return MediaService();
}
