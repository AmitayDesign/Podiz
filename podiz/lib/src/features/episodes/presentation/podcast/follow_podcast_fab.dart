import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/src/features/podcast/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';

class FollowPodcastFab extends ConsumerWidget {
  final String podcastId;
  final String imageUrl;

  const FollowPodcastFab({
    Key? key,
    required this.podcastId,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authManager = ref.watch(authManagerProvider); //!
    final isFollowing = authManager.isFollowing(podcastId);

    return FloatingActionButton.extended(
      backgroundColor: context.colorScheme.primary,
      onPressed: () => isFollowing
          ? authManager.unfollowShow(podcastId)
          : authManager.followShow(podcastId),
      icon: PodcastAvatar(imageUrl: imageUrl, size: 24),
      label: Text(
        isFollowing ? 'UNFOLLOW CAST'.hardcoded : 'FOLLOW CAST'.hardcoded,
        style: context.textTheme.titleSmall,
      ),
    );
  }
}
