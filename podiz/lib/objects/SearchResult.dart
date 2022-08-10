import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/Podcaster.dart';

class SearchResult {
  String uid;
  String name;
  String image_url;

  //podcast
  int? duration_ms;
  String? show_name;
  String? description;
  String? show_uri;
  int? comments;
  List<String>? commentsImg;
  String? release_date;
  int? watching;

  //podcaster
  String? publisher;
  int? total_episodes;
  List<String>? podcasts;
  List<String>? followers;

  SearchResult(
      {required this.uid,
      required this.name,
      required this.image_url,
      this.show_name,
      this.duration_ms,
      this.description,
      this.show_uri,
      this.publisher,
      this.total_episodes,
      this.podcasts,
      this.comments,
      this.commentsImg,
      this.release_date,
      this.followers,
      this.watching});

  Podcast searchResultToPodcast() {
    return Podcast(uid,
        name: name,
        description: description!,
        duration_ms: duration_ms!,
        show_name: show_name!,
        show_uri: show_uri!,
        image_url: image_url,
        comments: comments!,
        commentsImg: commentsImg!,
        release_date: release_date!,
        watching: watching!);
  }

  Podcaster searchResultToPodcaster() {
    return Podcaster(uid,
        name: name,
        publisher: publisher!,
        description: description!,
        image_url: image_url,
        total_episodes: total_episodes!,
        podcasts: podcasts!,
        followers: followers!);
  }
}
