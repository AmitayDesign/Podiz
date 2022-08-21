// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: json['id'] as String? ?? '',
      text: json['text'] as String,
      episodeId: json['episodeId'] as String,
      userId: json['userId'] as String,
      timestamp: durationFromMs(json['timestamp'] as int),
      parentIds: (json['parentIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      parentUserId: json['parentUserId'] as String?,
      replyCount: json['replyCount'] as int? ?? 0,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'episodeId': instance.episodeId,
      'userId': instance.userId,
      'timestamp': msFromDuration(instance.timestamp),
      'parentIds': instance.parentIds,
      'parentUserId': instance.parentUserId,
      'replyCount': instance.replyCount,
    };
