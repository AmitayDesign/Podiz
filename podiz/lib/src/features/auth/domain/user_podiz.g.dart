// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_podiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPodiz _$UserPodizFromJson(Map<String, dynamic> json) => UserPodiz(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      followers: (json['followers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      following: (json['following'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrl: json['imageUrl'] as String?,
      lastListened: json['lastListened'] as String?,
      favPodcasts: (json['favPodcasts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      emailVerified: json['emailVerified'] as bool?,
    );

Map<String, dynamic> _$UserPodizToJson(UserPodiz instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'imageUrl': instance.imageUrl,
      'emailVerified': instance.emailVerified,
      'lastListened': instance.lastListened,
      'followers': instance.followers,
      'following': instance.following,
      'favPodcasts': instance.favPodcasts,
    };
