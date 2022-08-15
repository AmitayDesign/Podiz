String dateFormatter(String date) {
  List<String> dateList = date.split("-");
  return "${dateList[2]}/${dateList[1]}/${dateList[0]}";
}

String timeFormatter(int time) {
  double minutes = ((time / (1000 * 60)) % 60);
  double hours = ((time / (1000 * 60 * 60)) % 24);
  if (hours.floor() > 0) {
    return "${hours.floor()}h ${minutes.floor()}m";
  } else {
    return "${minutes.floor()}m";
  }
}

String timePlayerFormatter(int time) {
  final timeString = Duration(milliseconds: time).toString();
  final timeDisplay = timeString.split('.').first;
  if (timeDisplay.startsWith('0:')) return timeDisplay.substring(2);
  return timeDisplay;
}
