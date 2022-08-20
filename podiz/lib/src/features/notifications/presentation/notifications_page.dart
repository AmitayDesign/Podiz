import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/common_widgets/empty_screen.dart';
import 'package:podiz/src/common_widgets/episode_subtitle.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/features/discussion/presentation/comment/comment_card.dart';
import 'package:podiz/src/features/episodes/presentation/home_screen.dart';
import 'package:podiz/src/features/notifications/presentation/notifications_bar.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(notificationsFilterProvider);
    final notificationsValue = ref.watch(notificationsStreamProvider);
    return notificationsValue.when(
        loading: () => EmptyScreen.loading(),
        error: (e, _) => EmptyScreen.text(
              'There was an error displaying the notifications.',
            ),
        data: (notifications) {
          final comments = filter == null
              ? notifications.values.expand((n) => n)
              : notifications[filter]!;
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: NotificationsBar(notifications),
            body: CustomScrollView(
              slivers: [
                // so it doesnt start behind the app bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: GradientBar.backgroundHeight + 16),
                ),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final comment =
                          comments.elementAt(i).notificationToComment();
                      final episodeId = comment.episodeId;
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            EpisodeSubtitle(episodeId),
                            CommentCard(comment, episodeId: episodeId)
                          ],
                        ),
                      );
                    },
                    childCount: comments.length,
                  ),
                ),

                // so it doesnt end behind the bottom bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: HomeScreen.bottomBarHeigh),
                ),
              ],
            ),
          );
        });
  }
}
