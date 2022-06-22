import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/aspect/typedefs.dart';
import 'package:podiz/objects/Comments.dart';

part 'Podcast.g.dart';

@JsonSerializable()
class Podcast with EquatableMixin {
  String? uid;
  String name;
  String description;
  int duration_ms;
  String show_name;
  String show_uri;
  String image_url;

  Podcast(this.uid,{
    required this.name,
    required this.description,
    required this.duration_ms,
    required this.show_name,
    required this.show_uri,
    required this.image_url,
  });

  factory Podcast.fromFirestore(Doc doc) =>
      Podcast.fromJson(doc.data()!..['uid'] = doc.id);

  factory Podcast.fromJson(Map<String, dynamic> json) =>
      _$PodcastFromJson(json);

  Map<String, dynamic> toJson() => _$PodcastToJson(this);

  factory Podcast.copyFrom(Podcast user) => Podcast.fromJson(user.toJson());

  @override
  String toString() => " user + ${this.uid} : \n{(name : ${this.name};\n";

  @override
  List<Object> get props => [name];
}
