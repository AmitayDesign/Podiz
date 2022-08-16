// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: json['id'] as String,
      episodeId: json['episodeUid'] as String,
      userId: json['userUid'] as String,
      text: json['comment'] as String,
      time: json['time'] as int,
      lvl: json['lvl'] as int,
      parentIds: (json['parents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'episodeUid': instance.episodeId,
      'userUid': instance.userId,
      'comment': instance.text,
      'time': instance.time,
      'lvl': instance.lvl,
      'parents': instance.parentIds,
    };
