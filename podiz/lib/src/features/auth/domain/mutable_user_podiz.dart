import 'package:podiz/src/features/auth/domain/user_podiz.dart';

extension MutableUserPodiz on UserPodiz {
  UserPodiz updateEmail(String email) => _copyWith(email: email);

  UserPodiz updateLastListened(String episodeId) =>
      _copyWith(lastListened: episodeId);

  UserPodiz _copyWith({
    String? lastListened,
    String? email,
  }) =>
      UserPodiz(
        id: id,
        name: name,
        email: email ?? this.email,
        followers: followers,
        following: following,
        imageUrl: imageUrl,
        lastListened: lastListened ?? this.lastListened,
        favPodcasts: favPodcasts,
      );
}
