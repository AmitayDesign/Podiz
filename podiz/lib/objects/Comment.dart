import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/aspect/typedefs.dart';

part 'Comment.g.dart';

@JsonSerializable()
class Comment with EquatableMixin {
  String id;
  String episodeUid;
  String userUid;
  String timestamp;
  String comment;
  int time;
  int lvl;
  List<String> parents;
  @JsonKey(ignore: true)
  Map<String, Comment>? replies;

  Comment(
    this.id, {
    required this.episodeUid,
    required this.userUid,
    required this.timestamp,
    required this.comment,
    required this.time,
    required this.lvl,
    required this.parents,
  });

  factory Comment.fromFirestore(Doc doc) =>
      Comment.fromJson(doc.data()!..['id'] = doc.id);

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);

  factory Comment.copyFrom(Comment user) => Comment.fromJson(user.toJson());

  @override
  String toString() => " user + $episodeUid : \n{(name : $comment; $replies\n";

  @override
  // TODO: implement props
  List<Object?> get props => [id];
}
