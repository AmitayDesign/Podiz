import 'package:podiz/src/features/auth/domain/user_podiz.dart';

extension MutableUserPodiz on UserPodiz {
  UserPodiz updateLastListenedEpisode(String episodeId) => UserPodiz(
        id: id,
        name: name,
        email: email,
        followers: followers,
        following: following,
        imageUrl: imageUrl,
        lastListenedEpisodeId: episodeId,
        favPodcastIds: favPodcastIds,
      );
}
