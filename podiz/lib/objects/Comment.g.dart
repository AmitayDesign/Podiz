// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      json['id'] as String,
      uid: json['uid'] as String,
      timestamp: json['timestamp'] as String,
      comment: json['comment'] as String,
      time: json['time'] as int,
      lvl: json['lvl'] as int,
      parents:
          (json['parents'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'timestamp': instance.timestamp,
      'comment': instance.comment,
      'time': instance.time,
      'lvl': instance.lvl,
      'parents': instance.parents,
    };
