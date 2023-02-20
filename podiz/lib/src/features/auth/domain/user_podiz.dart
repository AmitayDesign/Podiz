// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/src/utils/doc_typedef.dart';

import 'app_user.dart';

part 'user_podiz.g.dart';

@JsonSerializable()
class UserPodiz extends AppUser {
  /// Returns whether the users email address has been verified.
  /// Only available for the current app user
  final bool? emailVerified;

  @JsonKey(defaultValue: false)
  final bool? verified;

  final String? lastListened;

  @JsonKey(defaultValue: [])
  final List<String> followers;

  @JsonKey(defaultValue: [])
  final List<String> following;

  @JsonKey(defaultValue: [])
  final List<String> favPodcasts;

  const UserPodiz({
    required String id,
    required String name,
    required String? email,
    required this.followers,
    required this.following,
    required String? imageUrl,
    required this.lastListened,
    required this.favPodcasts,
    this.emailVerified,
    this.verified,
  }) : super(id: id, name: name, email: email, imageUrl: imageUrl);

  factory UserPodiz.fromFirestore(Doc doc, {bool? emailVerified}) =>
      UserPodiz.fromJson(
        doc.data()!
          ..['id'] = doc.id
          ..['emailVerified'] = emailVerified,
      );

  factory UserPodiz.fromJson(Map<String, dynamic> json) =>
      _$UserPodizFromJson(json);

  Map<String, dynamic> toJson() => _$UserPodizToJson(this);

  @override
  List<Object> get props => [id];
}
