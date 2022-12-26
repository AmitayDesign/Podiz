import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/src/utils/doc_typedef.dart';

part 'podcast.g.dart';

@JsonSerializable()
class Podcast with EquatableMixin {
  final String id;
  final String name;
  final String publisher;
  final String description;
  final String? imageUrl;

  @JsonKey(defaultValue: [])
  final List<String> followers;

  const Podcast({
    required this.id,
    required this.name,
    required this.publisher,
    required this.description,
    required this.imageUrl,
    required this.followers,
  });

  factory Podcast.fromFirestore(Doc doc) =>
      Podcast.fromJson(doc.data()!..['id'] = doc.id);

  factory Podcast.fromJson(Map<String, dynamic> json) =>
      _$PodcastFromJson(json);

  Map<String, dynamic> toJson() => _$PodcastToJson(this);

  @override
  List<Object> get props => [name];

  @override
  String toString() {
    return 'Podcast(id: $id, name: $name, publisher: $publisher, description: $description, imageUrl: $imageUrl, followers: $followers)';
  }
}
