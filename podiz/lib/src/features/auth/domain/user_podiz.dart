// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/aspect/typedefs.dart';

part 'user_podiz.g.dart';

@JsonSerializable()
class UserPodiz with EquatableMixin {
  final String id;
  final String name;
  final String email;

  @JsonKey(defaultValue: [])
  final List<String> followers;

  @JsonKey(defaultValue: [])
  final List<String> following;

  // TODO can imageUrl be null?
  @JsonKey(name: 'image_url')
  final String imageUrl;

  // TODO make lastListenedEpisodeId nullable
  @JsonKey(name: 'lastListened')
  final String lastListenedEpisodeId;

  @JsonKey(name: 'favPodcasts', defaultValue: [])
  final List<String> favPodcastIds;

  UserPodiz({
    required this.id,
    required this.name,
    required this.email,
    required this.followers,
    required this.following,
    required this.imageUrl,
    required this.lastListenedEpisodeId,
    required this.favPodcastIds,
  });

  factory UserPodiz.fromFirestore(Doc doc) =>
      UserPodiz.fromJson(doc.data()!..['id'] = doc.id);

  factory UserPodiz.fromJson(Map<String, dynamic> json) =>
      _$UserPodizFromJson(json);

  Map<String, dynamic> toJson() => _$UserPodizToJson(this);

  factory UserPodiz.copyFrom(UserPodiz user) =>
      UserPodiz.fromJson(user.toJson());

  @override
  String toString() =>
      'UserPodiz(id: $id, name: $name, email: $email, followers: $followers, following: $following, imageUrl: $imageUrl, lastListenedEpisodeId: $lastListenedEpisodeId, favPodcastIds: $favPodcastIds)';

  @override
  List<Object> get props => [id];
}
