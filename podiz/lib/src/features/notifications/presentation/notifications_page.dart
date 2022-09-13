import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/empty_screen.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/grouped_comments.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/episodes/presentation/home_screen.dart';
import 'package:podiz/src/features/notifications/presentation/notifications_bar.dart';
import 'package:podiz/src/features/player/presentation/player.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(notificationsFilterProvider);
    final user = ref.watch(currentUserProvider);
    final commentsValue = ref.watch(userRepliesStreamProvider(user.id));
    //TODO empty screen
    return commentsValue.when(
        loading: () => EmptyScreen.loading(),
        error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: EmptyScreen.text(
                'There was an error displaying the notifications.',
              ),
            ),
        data: (comments) {
          if (comments.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: EmptyScreen.text(
                'Notifications will appear when someone replies to your comments',
              ),
            );
          }
          late final List<Comment> filteredComments;
          if (filter == null) {
            filteredComments = comments;
          } else {
            filteredComments = comments
                .where((comment) => comment.episodeId == filter)
                .toList();
          }
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: NotificationsBar(comments),
            body: CustomScrollView(
              slivers: [
                // so it doesnt start behind the app bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: GradientBar.backgroundHeight + 16),
                ),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final comment = filteredComments.elementAt(i);
                      final episodeId = comment.episodeId;
                      return GroupedComments(episodeId, [comment]);
                    },
                    childCount: filteredComments.length,
                  ),
                ),

                // so it doesnt end behind the bottom bar
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: HomeScreen.bottomBarHeigh + Player.height,
                  ),
                ),
              ],
            ),
          );
        });
  }
}
