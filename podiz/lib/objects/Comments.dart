// import 'dart:io';

// import 'package:equatable/equatable.dart';
// import 'package:json_annotation/json_annotation.dart';
// import 'package:podiz/aspect/typedefs.dart';

// part 'Comments.g.dart';

// @JsonSerializable()
// class Comments with EquatableMixin {
//   String uid;
//   String userUid;
//   String timeStamp;
//   String comment;
//   //TODO try a composite!!!
//   Comments(
//     this.uid, {
//     required this.userUid,
//     required this.timeStamp,
//     required this.comment,
//   });

//   factory Comments.fromFirestore(Doc doc) =>
//       Comments.fromJson(doc.data()!..['uid'] = doc.id);

//   factory Comments.fromJson(Map<String, dynamic> json) =>
//       _$CommentsFromJson(json);

//   Map<String, dynamic> toJson() => _$CommentsToJson(this);

//   factory Comments.copyFrom(Comments user) =>
//       Comments.fromJson(user.toJson());

//   @override
//   String toString() =>
//       " user + ${this.uid} : \n{(name : ${this.name};\n";

//   @override
//   List<Object> get props => [name];
// }
