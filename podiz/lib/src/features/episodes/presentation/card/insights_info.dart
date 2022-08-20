import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/stacked_avatars.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/theme/context_theme.dart';

class InsightsInfo extends ConsumerWidget {
  final Episode episode;
  final Color? borderColor;
  const InsightsInfo({Key? key, required this.episode, this.borderColor})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveEpisode =
        ref.watch(episodeStreamProvider(episode.id)).valueOrNull ?? episode;
    final imageUrls = liveEpisode.usersWatching
        .map((userId) =>
            ref.watch(userFutureProvider(userId)).valueOrNull?.imageUrl)
        .toList();
    return Row(
      children: [
        imageUrls.length > 1
            ? StackedAvatars(
                imageUrls: imageUrls,
                borderColor: borderColor,
              )
            : Consumer(
                builder: (context, ref, _) {
                  final user = ref.watch(currentUserProvider);
                  return UserAvatar(user: user);
                },
              ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            liveEpisode.commentsCount == 0
                ? Locales.string(context, "noinsigths")
                : liveEpisode.commentsCount == 1
                    ? '1 insight'
                    : '${liveEpisode.commentsCount} insights',
            style: context.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
