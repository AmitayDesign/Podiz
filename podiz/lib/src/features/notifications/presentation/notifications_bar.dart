import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/objects/user/NotificationPodiz.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/notifications/presentation/episode_chip.dart';
import 'package:podiz/src/theme/context_theme.dart';

final notificationsFilterProvider = StateProvider<String?>((ref) => null);

class NotificationsBar extends ConsumerWidget with PreferredSizeWidget {
  final Map<String, List<NotificationPodiz>> notifications;
  const NotificationsBar(this.notifications, {Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(GradientBar.backgroundHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(notificationsFilterProvider);
    return GradientBar(
      titleSpacing: 0,
      title: SizedBox(
        height: 24,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: notifications.length + 1,
          separatorBuilder: (context, i) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            if (i == 0) {
              return EpisodeChip(
                null,
                counter: notifications.values.expand((n) => n).length,
                color: filter == null ? context.colorScheme.primary : null,
                onTap: () =>
                    ref.read(notificationsFilterProvider.notifier).state = null,
              );
            }
            final episodeId = notifications.keys.elementAt(i - 1);
            final episodeValue = ref.watch(episodeFutureProvider(episodeId));
            return episodeValue.when(
              loading: () => const Text('loading'),
              error: (e, _) => const Text('error'),
              // loading: () => const SizedBox.shrink(),
              // error: (e, _) => const SizedBox.shrink(),
              data: (episode) => EpisodeChip(
                episode,
                counter: notifications[episodeId]!.length,
                color:
                    filter == episode.id ? context.colorScheme.primary : null,
                onTap: () => ref
                    .read(notificationsFilterProvider.notifier)
                    .state = episode.id,
              ),
            );
          },
        ),
      ),
    );
  }
}
