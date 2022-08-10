import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/objects/Comment.dart';

part 'User.g.dart';

@JsonSerializable()
class UserPodiz with EquatableMixin {
  late String uid;
  String name;
  String email;
  List<String> followers;
  List<String> following;
  String image_url;
  String lastListened;
  List<String> favPodcasts;
  List<Comment> comments; //change this to InfoComment;

  UserPodiz(this.uid,
      {required this.name,
      required this.email,
      required this.followers,
      required this.following,
      required this.image_url,
      required this.lastListened,
      required this.favPodcasts,
      required this.comments});

  factory UserPodiz.fromFirestore(Doc doc) =>
      UserPodiz.fromJson(doc.data()!..['uid'] = doc.id);

  factory UserPodiz.fromJson(Map<String, dynamic> json) =>
      _$UserPodizFromJson(json);

  Map<String, dynamic> toJson() => _$UserPodizToJson(this);

  factory UserPodiz.copyFrom(UserPodiz user) =>
      UserPodiz.fromJson(user.toJson());

  @override
  String toString() =>
      " user + $uid : \n{(name : $name;\nemail : $email; ${followers.length}; ${following.length}\n";

  @override
  List<Object> get props => [name];
}
