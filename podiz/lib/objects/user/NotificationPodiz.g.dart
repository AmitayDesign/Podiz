// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NotificationPodiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPodiz _$NotificationPodizFromJson(Map<String, dynamic> json) =>
    NotificationPodiz(
      json['uid'] as String?,
      type: json['type'] as String,
      timestamp: json['timestamp'] as String,
      user: json['user'] as String,
      podcast: json['podcast'] as String,
      comment: json['comment'] as String,
    );

Map<String, dynamic> _$NotificationPodizToJson(NotificationPodiz instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'type': instance.type,
      'timestamp': instance.timestamp,
      'user': instance.user,
      'podcast': instance.podcast,
      'comment': instance.comment,
    };
