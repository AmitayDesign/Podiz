import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? dateFromTimestamp(Timestamp? timestamp) => timestamp?.toDate();
Timestamp? timestampFromDate(DateTime? date) =>
    date == null ? null : Timestamp.fromDate(date);