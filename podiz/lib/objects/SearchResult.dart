import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/domain/podcast.dart';

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
  List<String>? users_watching;

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
      this.users_watching});

  Episode toEpisode() {
    return Episode(
      id: uid,
      name: name,
      description: description!,
      duration: duration_ms!,
      showName: show_name!,
      showId: show_uri!,
      imageUrl: image_url,
      commentsCount: comments!,
      commentImageUrls: commentsImg!,
      releaseDateString: release_date!,
      userIdsWatching: users_watching!,
    );
  }

  Podcast toPodcast() {
    return Podcast(
        id: uid,
        name: name,
        publisher: publisher!,
        description: description!,
        imageUrl: image_url,
        totalEpisodes: total_episodes!,
        episodeIds: podcasts!,
        followers: followers!);
  }

  factory SearchResult.fromEpisode(Episode episode) {
    return SearchResult(
      uid: episode.id,
      name: episode.name,
      description: episode.description,
      duration_ms: episode.duration,
      show_name: episode.showName,
      show_uri: episode.showId,
      image_url: episode.imageUrl,
      comments: episode.commentsCount,
      commentsImg: episode.commentImageUrls,
      release_date: episode.releaseDateString,
      users_watching: episode.userIdsWatching,
    );
  }
}
