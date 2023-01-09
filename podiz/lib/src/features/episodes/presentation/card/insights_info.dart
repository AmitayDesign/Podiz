import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/stacked_avatars.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:skeletons/skeletons.dart';

class InsightsInfo extends ConsumerWidget {
  final Episode episode;
  final Color? borderColor;
  const InsightsInfo({Key? key, required this.episode, this.borderColor})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveEpisode =
        ref.watch(episodeStreamProvider(episode.id)).valueOrNull ?? episode;
    final comments =
        ref.watch(allLevelCommentsStreamProvider(liveEpisode.id)).value ?? [];
    final users = comments
        .map((comment) => comment.userId)
        .toSet()
        .take(3)
        .map((userId) => ref.watch(userFutureProvider(userId)).valueOrNull);
    return Row(
      children: [
        users.length > 1
            ? StackedAvatars(
                imageUrls: users.map((user) => user?.imageUrl).toList(),
                borderColor: borderColor,
              )
            : Consumer(
                builder: (context, ref, _) {
                  final user = comments.isEmpty
                      ? ref.watch(currentUserProvider)
                      : users.first;
                  if (user != null) return UserAvatar(user: user);
                  return const SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                      width: 32,
                      height: 32,
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            comments.isEmpty
                ? Locales.string(context, "noinsigths")
                : comments.length == 1
                    ? '1 insight'
                    : '${comments.length} insights',
            style: context.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
