import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';
import 'package:podiz/src/features/podcast/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';

class PodcastFollowFab extends ConsumerWidget {
  final String podcastId;
  final String imageUrl;

  const PodcastFollowFab({
    Key? key,
    required this.podcastId,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastRepository = ref.watch(podcastRepositoryProvider);
    final user = ref.watch(currentUserProvider);
    final isFollowing = user.favPodcastIds.contains(podcastId);

    return FloatingActionButton.extended(
      backgroundColor: context.colorScheme.primary,
      onPressed: () => isFollowing
          ? podcastRepository.unfollow(user.id, podcastId)
          : podcastRepository.follow(user.id, podcastId),
      icon: PodcastAvatar(
        podcastId: podcastId,
        imageUrl: imageUrl,
        size: 24,
      ),
      label: Text(
        isFollowing ? 'UNFOLLOW CAST'.hardcoded : 'FOLLOW CAST'.hardcoded,
        style: context.textTheme.titleSmall,
      ),
    );
  }
}
