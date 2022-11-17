import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';

class PodcastFollowFab extends ConsumerWidget {
  final String podcastId;
  final String? imageUrl;

  const PodcastFollowFab({
    Key? key,
    required this.podcastId,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isFollowing = user.favPodcasts.contains(podcastId);

    return FloatingActionButton.extended(
      backgroundColor: context.colorScheme.primary,
      onPressed: () {
        final podcastRepository = ref.read(podcastRepositoryProvider);
        isFollowing
            ? podcastRepository.unfollow(user.id, podcastId)
            : podcastRepository.follow(user.id, podcastId);
      },
      // icon: PodcastAvatar(
      //   imageUrl: imageUrl,
      //   size: 24,
      // ),
      label: Text(
        isFollowing ? 'UNFOLLOW CAST'.hardcoded : 'FOLLOW CAST'.hardcoded,
        style: context.textTheme.titleSmall,
      ),
    );
  }
}
