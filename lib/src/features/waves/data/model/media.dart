import 'package:freezed_annotation/freezed_annotation.dart';

part 'media.freezed.dart';

@freezed
abstract class Media with _$Media {
  const factory Media({required String name, required String path}) = _Media;
}
