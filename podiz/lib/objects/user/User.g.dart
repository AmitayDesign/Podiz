// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'User.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPodiz _$UserPodizFromJson(Map<String, dynamic> json) => UserPodiz(
      json['uid'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      followers:
          (json['followers'] as List<dynamic>).map((e) => e as String).toList(),
      following:
          (json['following'] as List<dynamic>).map((e) => e as String).toList(),
      image_url: json['image_url'] as String,
      lastListened: json['lastListened'] as String,
      favPodcasts: (json['favPodcasts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      comments: (json['comments'] as List<dynamic>)
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserPodizToJson(UserPodiz instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'followers': instance.followers,
      'following': instance.following,
      'image_url': instance.image_url,
      'lastListened': instance.lastListened,
      'favPodcasts': instance.favPodcasts,
      'comments': instance.comments,
    };
