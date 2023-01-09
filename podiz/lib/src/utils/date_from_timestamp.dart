import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? dateFromTimestamp(Timestamp? timestamp) => timestamp?.toDate();
Timestamp? timestampFromDate(DateTime? date) =>
    date == null ? null : Timestamp.fromDate(date);

String stringFromDate(DateTime date) {
  final year = date.year.toString();
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return "$year-$month-$day";
}
