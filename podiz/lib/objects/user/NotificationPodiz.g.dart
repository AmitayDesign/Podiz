// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NotificationPodiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPodiz _$NotificationPodizFromJson(Map<String, dynamic> json) =>
    NotificationPodiz(
      json['uid'] as String?,
      timestamp: json['timestamp'] as String,
      userUid: json['userUid'] as String,
      episodeUid: json['episodeUid'] as String,
      comment: json['comment'] as String,
      time: json['time'] as int,
      lvl: json['lvl'] as int,
      parents:
          (json['parents'] as List<dynamic>).map((e) => e as String).toList(),
      id: json['id'] as String,
    );

Map<String, dynamic> _$NotificationPodizToJson(NotificationPodiz instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'timestamp': instance.timestamp,
      'userUid': instance.userUid,
      'episodeUid': instance.episodeUid,
      'comment': instance.comment,
      'time': instance.time,
      'lvl': instance.lvl,
      'parents': instance.parents,
      'id': instance.id,
    };
