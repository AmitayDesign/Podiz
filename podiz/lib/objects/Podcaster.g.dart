// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Podcaster.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Podcaster _$PodcasterFromJson(Map<String, dynamic> json) => Podcaster(
      json['uid'] as String?,
      name: json['name'] as String,
      publisher: json['publisher'] as String,
      description: json['description'] as String,
      image_url: json['image_url'] as String,
      total_episodes: json['total_episodes'] as int,
      podcasts:
          (json['podcasts'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$PodcasterToJson(Podcaster instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'publisher': instance.publisher,
      'description': instance.description,
      'image_url': instance.image_url,
      'total_episodes': instance.total_episodes,
      'podcasts': instance.podcasts,
    };
