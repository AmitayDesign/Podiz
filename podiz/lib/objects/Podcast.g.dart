// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Podcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Podcast _$PodcastFromJson(Map<String, dynamic> json) => Podcast(
      json['uid'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      duration_ms: json['duration_ms'] as int,
      show_name: json['show_name'] as String,
      show_uri: json['show_uri'] as String,
      image_url: json['image_url'] as String,
      comments: json['comments'] as int,
      commentsImg: (json['commentsImg'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      release_date: json['release_date'] as String,
      watching: json['watching'] as int,
    );

Map<String, dynamic> _$PodcastToJson(Podcast instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'description': instance.description,
      'duration_ms': instance.duration_ms,
      'show_name': instance.show_name,
      'show_uri': instance.show_uri,
      'image_url': instance.image_url,
      'comments': instance.comments,
      'commentsImg': instance.commentsImg,
      'release_date': instance.release_date,
      'watching': instance.watching,
    };