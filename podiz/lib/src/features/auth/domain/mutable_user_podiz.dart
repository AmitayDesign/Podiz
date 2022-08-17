import 'package:podiz/src/features/auth/domain/user_podiz.dart';

extension MutableUserPodiz on UserPodiz {
  UserPodiz updateLastListenedEpisode(String episodeId) => UserPodiz.fromJson(
        toJson()
          ..['id'] = id
          ..['lastListened'] = episodeId,
      );
}
