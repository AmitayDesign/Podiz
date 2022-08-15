import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:podiz/aspect/typedefs.dart';

part 'episode.g.dart';

@JsonSerializable()
class Episode with EquatableMixin {
  String id;
  String name;
  String description;

  @JsonKey(name: 'duration_ms') //TODO convert to seconds
  int duration;

  @JsonKey(name: 'image_url')
  String imageUrl;

  @JsonKey(name: 'comments', defaultValue: 0)
  int commentsCount;

  @JsonKey(name: 'commentsImg', defaultValue: [])
  List<String> commentImageUrls;

  @JsonKey(name: 'release_date')
  String releaseDateString; //TODO make it a DateTime

  @JsonKey(name: 'watching', defaultValue: 0)
  int peopleWatchingCount;

  @JsonKey(name: 'show_uri')
  String showId;

  @JsonKey(name: 'show_name')
  String showName;

  Episode(
    this.id, {
    required this.name,
    required this.description,
    required this.duration,
    required this.showName,
    required this.showId,
    required this.imageUrl,
    required this.commentsCount,
    required this.commentImageUrls,
    required this.releaseDateString,
    required this.peopleWatchingCount,
  });

  // TODO GET SHOW
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

  factory Episode.copyFrom(Episode user) => Episode.fromJson(user.toJson());

  @override
  String toString() => " user + $id : \n{(name : $name;\n";

  @override
  List<Object> get props => [id];
}