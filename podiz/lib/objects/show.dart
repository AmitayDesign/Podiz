import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/aspect/typedefs.dart';

part 'show.g.dart';

@JsonSerializable()
class Show with EquatableMixin {
  String? uid;
  String name;
  String publisher;
  String description;
  String image_url;
  int total_episodes;
  List<String> podcasts;
  List<String> followers;

  Show(
    this.uid, {
    required this.name,
    required this.publisher,
    required this.description,
    required this.image_url,
    required this.total_episodes,
    required this.podcasts,
    required this.followers,
  });

  factory Show.fromFirestore(Doc doc) =>
      Show.fromJson(doc.data()!..['uid'] = doc.id);

  factory Show.fromJson(Map<String, dynamic> json) => _$ShowFromJson(json);

  Map<String, dynamic> toJson() => _$ShowToJson(this);

  factory Show.copyFrom(Show user) => Show.fromJson(user.toJson());

  @override
  String toString() => " user + $uid : \n{(name : $name;\n";

  @override
  List<Object> get props => [name];
}
