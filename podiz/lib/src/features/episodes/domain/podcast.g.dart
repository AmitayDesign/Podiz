// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Podcast _$PodcastFromJson(Map<String, dynamic> json) => Podcast(
      id: json['id'] as String,
      name: json['name'] as String,
      publisher: json['publisher'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      totalEpisodes: json['total_episodes'] as int,
      episodeIds: (json['podcasts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      followers: (json['followers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$PodcastToJson(Podcast instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'publisher': instance.publisher,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'total_episodes': instance.totalEpisodes,
      'podcasts': instance.episodeIds,
      'followers': instance.followers,
    };
