// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_podiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPodiz _$UserPodizFromJson(Map<String, dynamic> json) => UserPodiz(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      followers: (json['followers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      following: (json['following'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrl: json['image_url'] as String,
      lastListenedEpisodeId: json['lastListened'] as String,
      favPodcastIds: (json['favPodcasts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$UserPodizToJson(UserPodiz instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'followers': instance.followers,
      'following': instance.following,
      'image_url': instance.imageUrl,
      'lastListened': instance.lastListenedEpisodeId,
      'favPodcasts': instance.favPodcastIds,
    };
