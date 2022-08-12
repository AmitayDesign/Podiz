// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Show _$ShowFromJson(Map<String, dynamic> json) => Show(
      json['uid'] as String?,
      name: json['name'] as String,
      publisher: json['publisher'] as String,
      description: json['description'] as String,
      image_url: json['image_url'] as String,
      total_episodes: json['total_episodes'] as int,
      podcasts:
          (json['podcasts'] as List<dynamic>).map((e) => e as String).toList(),
      followers:
          (json['followers'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ShowToJson(Show instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'publisher': instance.publisher,
      'description': instance.description,
      'image_url': instance.image_url,
      'total_episodes': instance.total_episodes,
      'podcasts': instance.podcasts,
      'followers': instance.followers,
    };
