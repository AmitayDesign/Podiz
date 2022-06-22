import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/aspect/typedefs.dart';

part 'Podcaster.g.dart';

@JsonSerializable()
class Podcaster with EquatableMixin {
  String? uid;
  String name;
  String publisher;
  String description;
  String image_url;
  int total_episodes;
  List<String> podcasts;
  
  Podcaster(
    this.uid, {
    required this.name,
    required this.publisher,
    required this.description,
    required this.image_url,
    required this.total_episodes,
    required this.podcasts,
  });

  factory Podcaster.fromFirestore(Doc doc) =>
      Podcaster.fromJson(doc.data()!..['uid'] = doc.id);

  factory Podcaster.fromJson(Map<String, dynamic> json) =>
      _$PodcasterFromJson(json);

  Map<String, dynamic> toJson() => _$PodcasterToJson(this);

  factory Podcaster.copyFrom(Podcaster user) =>
      Podcaster.fromJson(user.toJson());

  @override
  String toString() =>
      " user + ${this.uid} : \n{(name : ${this.name};\n";

  @override
  List<Object> get props => [name];
}
