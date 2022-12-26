import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/notifications/presentation/episode_chip.dart';
import 'package:podiz/src/theme/context_theme.dart';

final notificationsFilterProvider = StateProvider<String?>((ref) => null);

class NotificationsBar extends ConsumerWidget with PreferredSizeWidget {
  final episodeCounters = <String, int>{};
  NotificationsBar(List<Comment> comments, {Key? key}) : super(key: key) {
    for (final comment in comments) {
      final counter = episodeCounters[comment.episodeId] ?? 0;
      episodeCounters[comment.episodeId] = counter + 1;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(GradientBar.backgroundHeight);

  int get total =>
      episodeCounters.values.fold(0, (total, count) => total + count);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(notificationsFilterProvider);
    return GradientBar(
      titleSpacing: 0,
      title: SizedBox(
        height: EpisodeChip.height,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: 1 + episodeCounters.length, // All + ...episodeNames
          itemBuilder: (context, i) {
            const padding = EdgeInsets.only(right: 8);
            if (i == 0) {
              return Padding(
                padding: padding,
                child: EpisodeChip(
                  null,
                  counter: total,
                  color: filter == null ? context.colorScheme.primary : null,
                  onTap: () => ref
                      .read(notificationsFilterProvider.notifier)
                      .state = null,
                ),
              );
            }
            final episodeId = episodeCounters.keys.elementAt(i - 1);
            final episodeValue = ref.watch(episodeFutureProvider(episodeId));
            return episodeValue.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (episode) => Padding(
                padding: padding,
                child: EpisodeChip(
                  episode,
                  counter: episodeCounters[episodeId]!,
                  color:
                      filter == episode.id ? context.colorScheme.primary : null,
                  onTap: () => ref
                      .read(notificationsFilterProvider.notifier)
                      .state = episode.id,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
