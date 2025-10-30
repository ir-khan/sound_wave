extension DurationFormat on Duration {
  String format() {
    if (inHours == 0) return toString().substring(2, 7);

    int hours = inSeconds ~/ 3600;
    int remainingSeconds = inSeconds % 3600;
    int minutes = remainingSeconds ~/ 60;

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr';
    // return toString().split('.').first;
  }
}
