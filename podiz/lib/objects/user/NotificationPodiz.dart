import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/objects/Comment.dart';

part 'NotificationPodiz.g.dart';

@JsonSerializable()
class NotificationPodiz {
  //Use abstract class maybe //change this!!!
  String? uid;
  String timestamp;
  String userUid;
  String episodeUid;
  //comment
  String comment;
  int time;
  int lvl;
  List<String> parents;

  // NotificationPodiz.follower(
  //   this.uid, {
  //   required this.type,
  //   required this.timestamp,
  //   required this.user,
  // });

  NotificationPodiz(
    this.uid, {
    required this.timestamp,
    required this.userUid,
    required this.episodeUid,
    required this.comment,
    required this.time,
    required this.lvl,
    required this.parents,
  });

  factory NotificationPodiz.fromFirestore(Doc doc) =>
      NotificationPodiz.fromJson(doc.data()!..['uid'] = doc.id);

  factory NotificationPodiz.fromJson(Map<String, dynamic> json) =>
      _$NotificationPodizFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPodizToJson(this);

  factory NotificationPodiz.copyFrom(NotificationPodiz user) =>
      NotificationPodiz.fromJson(user.toJson());

  Comment notificationToComment() {
    Comment c = Comment("",
        episodeUid: episodeUid,
        userUid: userUid,
        timestamp: timestamp,
        comment: comment,
        time: time,
        lvl: lvl,
        parents: parents);
    c.replies = {};
    return c;
  }
}
