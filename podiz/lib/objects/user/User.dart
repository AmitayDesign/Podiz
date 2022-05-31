import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/aspect/typedefs.dart';

part 'User.g.dart';

@JsonSerializable()
class UserPodiz with EquatableMixin {
  String uid;
  String name;
  String email;
  DateTime timestamp;
  

  @JsonKey(ignore: true)
  File? image;

  UserPodiz(
    this.uid, {
    required this.name,
    required this.email,
    required this.timestamp,
  });

  factory UserPodiz.fromFirestore(Doc doc) =>
      UserPodiz.fromJson(doc.data()!..['uid'] = doc.id);

  factory UserPodiz.fromJson(Map<String, dynamic> json) =>
      _$UserPodizFromJson(json);

  Map<String, dynamic> toJson() => _$UserPodizToJson(this);

  factory UserPodiz.copyFrom(UserPodiz user) => UserPodiz.fromJson(user.toJson());

  @override
  String toString() =>
      " user + ${this.uid} : \n{(name : ${this.name};\nemail : ${this.email};\n";

  @override
  List<Object> get props => [name];
}
