import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/src/utils/duration_from_ms.dart';
import 'package:podiz/src/utils/firestore_refs.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment with EquatableMixin {
  final String id;
  final String text;
  final String episodeId;
  final String userId;

  @JsonKey(fromJson: durationFromMs)
  final Duration timestamp;

  final List<String> parentIds;
  final String? parentUserId;

  final int replyCount;

  Comment({
    this.id = '',
    required this.text,
    required this.episodeId,
    required this.userId,
    required this.timestamp,
    this.parentIds = const [],
    this.parentUserId,
    this.replyCount = 0,
  });

  factory Comment.fromFirestore(Doc doc) =>
      Comment.fromJson(doc.data()!..['id'] = doc.id);

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);

  @override
  List<Object?> get props => [id];

  @override
  String toString() {
    return 'Comment(id: $id, text: $text, episodeId: $episodeId, userId: $userId, timestamp: $timestamp, parentIds: $parentIds, parentUserId: $parentUserId, replyCount: $replyCount)';
  }
}
