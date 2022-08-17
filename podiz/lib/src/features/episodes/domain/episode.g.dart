// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Episode _$EpisodeFromJson(Map<String, dynamic> json) => Episode(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      duration: json['duration_ms'] as int,
      showName: json['show_name'] as String,
      showId: json['show_uri'] as String,
      imageUrl: json['image_url'] as String,
      commentsCount: json['comments'] as int? ?? 0,
      commentImageUrls: (json['commentsImg'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      releaseDateString: json['release_date'] as String,
      userIdsWatching: (json['users_watching'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$EpisodeToJson(Episode instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'duration_ms': instance.duration,
      'image_url': instance.imageUrl,
      'comments': instance.commentsCount,
      'commentsImg': instance.commentImageUrls,
      'release_date': instance.releaseDateString,
      'users_watching': instance.userIdsWatching,
      'show_uri': instance.showId,
      'show_name': instance.showName,
    };
