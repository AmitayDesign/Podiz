// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Episode _$EpisodeFromJson(Map<String, dynamic> json) => Episode(
      json['id'] as String,
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
      peopleWatchingCount: json['watching'] as int? ?? 0,
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
      'watching': instance.peopleWatchingCount,
      'show_uri': instance.showId,
      'show_name': instance.showName,
    };
