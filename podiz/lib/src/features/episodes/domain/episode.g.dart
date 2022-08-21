// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Episode _$EpisodeFromJson(Map<String, dynamic> json) => Episode(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      duration: durationFromMs(json['duration'] as int),
      showId: json['showId'] as String,
      imageUrl: json['imageUrl'] as String?,
      releaseDate: json['releaseDate'] as String,
      usersWatching: (json['usersWatching'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      commentsCount: json['commentsCount'] as int? ?? 0,
    );

Map<String, dynamic> _$EpisodeToJson(Episode instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'duration': msFromDuration(instance.duration),
      'releaseDate': instance.releaseDate,
      'showId': instance.showId,
      'usersWatching': instance.usersWatching,
      'commentsCount': instance.commentsCount,
    };
