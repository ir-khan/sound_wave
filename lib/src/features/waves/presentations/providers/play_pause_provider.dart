import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'play_pause_provider.g.dart';

@riverpod
class PlayPause extends _$PlayPause {
  @override
  bool build() => true;

  void setValue(bool newValue) => state = newValue;

  void toggle() => state = !state;
}
