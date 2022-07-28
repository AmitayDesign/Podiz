import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/aspect/typedefs.dart';

part 'Comment.g.dart';

@JsonSerializable()
class Comment with EquatableMixin {
  String id;
  String uid;
  String timestamp;
  String comment;
  int time;
  int lvl;
  List<String> parents;
  @JsonKey(ignore: true)
  Map<String, Comment>? replies;

  Comment(
    this.id, {
    required this.uid,
    required this.timestamp,
    required this.comment,
    required this.time,
    required this.lvl,
    required this.parents,
  });

  factory Comment.fromFirestore(Doc doc) =>
      Comment.fromJson(doc.data()!..['uid'] = doc.id);

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);

  factory Comment.copyFrom(Comment user) => Comment.fromJson(user.toJson());

  @override
  String toString() => " user + ${this.uid} : \n{(name : ${this.comment}; ${replies}\n";

  @override
  // TODO: implement props
  List<Object?> get props => [this.id];
}
