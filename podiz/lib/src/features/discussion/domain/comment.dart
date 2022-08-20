import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/src/utils/doc_typedef.dart';

part 'comment.g.dart';

//TODO get number of replies

@JsonSerializable()
class Comment with EquatableMixin {
  final String id;

  @JsonKey(name: 'episodeUid')
  final String episodeId; //!

  @JsonKey(name: 'userUid')
  final String userId;

  @JsonKey(name: 'comment')
  final String text;

  /// Comment timestamp in milliseconds
  final int time;

  final int lvl; //!

  @JsonKey(name: 'parents', defaultValue: [])
  final List<String> parentIds; //!

  @JsonKey(ignore: true)
  final Map<String, Comment> replies = {};

  Comment({
    required this.id,
    required this.episodeId,
    required this.userId,
    required this.text,
    required this.time,
    required this.lvl,
    this.parentIds = const [],
  });

  factory Comment.fromFirestore(Doc doc) =>
      Comment.fromJson(doc.data()!..['id'] = doc.id);

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);

  factory Comment.copyFrom(Comment user) => Comment.fromJson(user.toJson());

  @override
  String toString() => " user + $episodeId : \n{(name : $text; $replies\n";

  @override
  List<Object?> get props => [id];
}
