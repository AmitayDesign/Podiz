// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'User.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPodiz _$UserPodizFromJson(Map<String, dynamic> json) => UserPodiz(
      json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$UserPodizToJson(UserPodiz instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'timestamp': instance.timestamp.toIso8601String(),
    };
