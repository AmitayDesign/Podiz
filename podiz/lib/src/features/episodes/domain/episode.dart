import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/aspect/typedefs.dart';

part 'episode.g.dart';

@JsonSerializable()
class Episode with EquatableMixin {
  final String id;
  final String name;
  final String description; //! not used

  //TODO convert to seconds
  @JsonKey(name: 'duration_ms')
  final int duration;

  @JsonKey(name: 'image_url')
  final String imageUrl;

  //TODO remove from here to read by itself
  @JsonKey(name: 'comments', defaultValue: 0)
  final int commentsCount;

  @JsonKey(name: 'commentsImg', defaultValue: [])
  final List<String> commentImageUrls;
  //!

  @JsonKey(name: 'release_date')
  final String releaseDateString; //TODO make it a DateTime

  //TODO remove from here to read by itself
  @JsonKey(name: 'users_watching', defaultValue: [])
  final List<String> userIdsWatching;

  @JsonKey(name: 'show_uri')
  final String showId;

  @JsonKey(name: 'show_name')
  final String showName;

  Episode({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.showName,
    required this.showId,
    required this.imageUrl,
    required this.commentsCount,
    required this.commentImageUrls,
    required this.releaseDateString,
    required this.userIdsWatching,
  });

  // TODO check if they have show data
  factory Episode.fromSpotify(Map<String, dynamic> json) {
    return Episode.fromJson(json
      ..addAll({
        'uid': json["uri"],
        'image_url': json["images"][0]["url"],
        'release_date': json["release_date"],
        'show_uri': 'SHOW ID',
        'show_name': 'SHOW NAME',
      }));
  }

  factory Episode.fromFirestore(Doc doc) =>
      Episode.fromJson(doc.data()!..['id'] = doc.id);

  factory Episode.fromJson(Map<String, dynamic> json) =>
      _$EpisodeFromJson(json);

  factory Episode.copyFrom(Episode user) => Episode.fromJson(user.toJson());

  Map<String, dynamic> toJson() => _$EpisodeToJson(this);

  Map<String, dynamic> toFirestore() {
    // generate search array
    final searchArray = [];
    var prev = "";
    for (final letter in name.split('')) {
      prev += letter;
      final word = prev.toLowerCase();
      searchArray.add(word);
    }
    // return data
    return toJson()
      ..remove('uid')
      ..['searchArray'] = searchArray;
  }

  @override
  String toString() => " user + $id : \n{(name : $name;\n";

  @override
  List<Object> get props => [id];
}
