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
  double seconds = (time / 1000) % 60;
  double minutes = ((time / (1000 * 60)) % 60);
  double hours = ((time / (1000 * 60 * 60)) % 24);

  if (hours < 0) {
    return "${minutes.floor ()}:${seconds.floor()}";
  } else if (minutes > 0 && hours < 0) {
    return "${minutes.floor()}:${seconds.floor()}";
  } else {
    return "${hours.floor()}:${minutes.floor()}:${seconds.floor()}";
  }
}
