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
      final files = <XFile>[];
      for (final file in result.files) {
        if (allowedExtensions.contains(file.extension)) {
          files.add(XFile(file.path!, name: file.name));
        }
      }
      return files;
    } catch (e) {
      rethrow;
    }
  }
}

@riverpod
MediaService mediaService(Ref _) {
  return MediaService();
}

const allowedExtensions = [
  '3gp',
  'aa',
  'aac',
  'aax',
  'act',
  'aiff',
  'alac',
  'amr',
  'ape',
  'au',
  'awb',
  'dss',
  'dvf',
  'flac',
  'gsm',
  'iklax',
  'ivs',
  'm4a',
  'm4b',
  'm4p',
  'mmf',
  'movpkg	',
  'mp1',
  'mp2',
  'mp3',
  'mpc',
  'msv',
  'nmf',
  'ogg',
  'oga',
  'mogg',
  'opus',
  'ra',
  'rm',
  'raw',
  'rf64',
  'sln',
  'tta',
  'voc',
  'vox',
  'wav',
  'wma',
  'wv',
  'webm',
  '8svx',
  'cda',
];
