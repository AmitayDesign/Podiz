import 'package:json_annotation/json_annotation.dart';

part 'NotificationPodiz.g.dart';

@JsonSerializable()
class NotificationPodiz {
  //Use abstract class maybe
  String? uid;
  String type;
  String timestamp;
  String user;

  String podcast;
  String comment;

  // NotificationPodiz.follower(
  //   this.uid, {
  //   required this.type,
  //   required this.timestamp,
  //   required this.user,
  // });

  NotificationPodiz(
    this.uid, {
    required this.type,
    required this.timestamp,
    required this.user,
    required this.podcast,
    required this.comment,
  });

  factory NotificationPodiz.fromJson(Map<String, dynamic> json) =>
      _$NotificationPodizFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPodizToJson(this);

  factory NotificationPodiz.copyFrom(NotificationPodiz user) =>
      NotificationPodiz.fromJson(user.toJson());
      
}
