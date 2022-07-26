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
  int seconds = ((time / 1000) % 60).floor();
  int minutes = ((time / (1000 * 60)) % 60).floor();
  int hours = ((time / (1000 * 60 * 60)) % 24).floor();

  if (hours == 0) {
    String min = "$minutes", sec = "$seconds";
    if (minutes < 10) {
      min = "0$minutes";
    }
    if (seconds < 10) {
      sec = "0$seconds";
    }
    return "$min:$sec";
  }
  return "0$hours:$minutes:$seconds";
}
