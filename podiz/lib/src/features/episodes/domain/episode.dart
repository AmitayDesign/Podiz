import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/src/utils/doc_typedef.dart';
import 'package:podiz/src/utils/duration_from_ms.dart';

part 'episode.g.dart';

@JsonSerializable()
class Episode with EquatableMixin {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;

  @JsonKey(fromJson: durationFromMs, toJson: msFromDuration)
  final Duration duration;

  final String releaseDate;

  final String showId;

  @JsonKey(defaultValue: [])
  final List<String> usersWatching;

  @JsonKey(defaultValue: 0)
  final int commentsCount;

  const Episode({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.showId,
    required this.imageUrl,
    required this.releaseDate,
    required this.usersWatching,
    required this.commentsCount,
  });

  factory Episode.fromFirestore(Doc doc) =>
      Episode.fromJson(doc.data()!..['id'] = doc.id);

  factory Episode.fromJson(Map<String, dynamic> json) =>
      _$EpisodeFromJson(json);

  Map<String, dynamic> toJson() => _$EpisodeToJson(this);

  @override
  List<Object> get props => [id];

  @override
  String toString() {
    return 'Episode(id: $id, name: $name, description: $description, imageUrl: $imageUrl, duration: $duration, releaseDate: $releaseDate, showId: $showId, usersWatching: $usersWatching, commentsCount: $commentsCount)';
  }
}
