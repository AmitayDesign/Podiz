import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/aspect/typedefs.dart';

part 'podcast.g.dart';

@JsonSerializable()
class Podcast with EquatableMixin {
  final String id;
  final String name;
  final String publisher;
  final String description;

  @JsonKey(name: 'image_url')
  final String imageUrl;

  @JsonKey(name: 'total_episodes')
  final int totalEpisodes;

  @JsonKey(defaultValue: [])
  final List<String> podcasts;

  @JsonKey(defaultValue: [])
  final List<String> followers;

  Podcast({
    required this.id,
    required this.name,
    required this.publisher,
    required this.description,
    required this.imageUrl,
    required this.totalEpisodes,
    required this.podcasts,
    required this.followers,
  });

  factory Podcast.fromFirestore(Doc doc) =>
      Podcast.fromJson(doc.data()!..['id'] = doc.id);

  factory Podcast.fromJson(Map<String, dynamic> json) =>
      _$PodcastFromJson(json);

  Map<String, dynamic> toJson() => _$PodcastToJson(this);

  factory Podcast.copyFrom(Podcast user) => Podcast.fromJson(user.toJson());

  @override
  String toString() => " user + $id : \n{(name : $name;\n";

  @override
  List<Object> get props => [name];
}
