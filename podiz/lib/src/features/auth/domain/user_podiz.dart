// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/src/utils/doc_typedef.dart';

part 'user_podiz.g.dart';

@JsonSerializable()
class UserPodiz with EquatableMixin {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;

  final String? lastListened;

  @JsonKey(defaultValue: [])
  final List<String> followers;

  @JsonKey(defaultValue: [])
  final List<String> following;

  @JsonKey(defaultValue: [])
  final List<String> favPodcasts;

  const UserPodiz({
    required this.id,
    required this.name,
    required this.email,
    required this.followers,
    required this.following,
    required this.imageUrl,
    required this.lastListened,
    required this.favPodcasts,
  });

  factory UserPodiz.fromFirestore(Doc doc) =>
      UserPodiz.fromJson(doc.data()!..['id'] = doc.id);

  factory UserPodiz.fromJson(Map<String, dynamic> json) =>
      _$UserPodizFromJson(json);

  Map<String, dynamic> toJson() => _$UserPodizToJson(this);

  @override
  List<Object> get props => [id];

  @override
  String toString() {
    return 'UserPodiz(id: $id, name: $name, email: $email, imageUrl: $imageUrl, lastListened: $lastListened, followers: $followers, following: $following, favPodcasts: $favPodcasts)';
  }
}
