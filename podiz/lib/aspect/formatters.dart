String dateFormatter(String date) {
  List<String> dateList = date.split("-");
  return "${dateList[2]}/${dateList[1]}/${dateList[0]}";
}

String timeFormatter(int time) {
  double minutes = ((time / (1000 * 60)) % 60);
  double hours = ((time / (1000 * 60 * 60)) % 24);
  if (hours > 0) {
    return "${hours.ceil()}h ${minutes.ceil()}m";
  } else {
    return "${minutes.ceil()}m";
  }
}

String timePlayerFormatter(int time) {
  double seconds = (time / 1000) % 60;
  double minutes = ((time / (1000 * 60)) % 60);
  double hours = ((time / (1000 * 60 * 60)) % 24);
  if (minutes < 0) {
    return "${minutes.ceil()}:${seconds.ceil()}";
  } else if (minutes > 0 && hours < 0) {
    return "${minutes.ceil()}:${seconds.ceil()}";
  } else {
    return "${hours.ceil()}:${minutes.ceil()}:${seconds.ceil()}";
  }
}
