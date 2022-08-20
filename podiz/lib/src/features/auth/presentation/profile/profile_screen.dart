import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/empty_screen.dart';
import 'package:podiz/src/common_widgets/episode_subtitle.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/auth/presentation/profile/profile_follow_fab.dart';
import 'package:podiz/src/features/auth/presentation/profile/profile_sliver_header.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/presentation/comment/comment_card.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/skeleton_episode_avatar.dart';
import 'package:podiz/src/features/player/presentation/player.dart';
import 'package:podiz/src/theme/context_theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  const ProfileScreen(this.userId, {Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final bool isCurrentUser =
      ref.read(currentUserProvider).id == widget.userId;
  final scrollController = ScrollController();

  double get statusBarHeight => MediaQuery.of(context).padding.top;
  double get minHeight => statusBarHeight + GradientBar.height * 1.5;
  double get maxHeight => statusBarHeight + 296;

  void snapHeader() {
    final distance = maxHeight - minHeight;
    final offset = scrollController.offset;
    if (offset > 0 && offset < distance) {
      final snapOffset = offset / distance > 0.5 ? distance : 0.0;
      Future.microtask(
        () => scrollController.animateTo(
          snapOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userValue = ref.watch(userStreamProvider(widget.userId));
    return userValue.when(
      loading: () => EmptyScreen.loading(),
      error: (e, _) => EmptyScreen.text(
        'There was an error opening this profile.',
      ),
      data: (user) => Scaffold(
        extendBody: true,
        body: NotificationListener<ScrollEndNotification>(
          onNotification: (_) {
            snapHeader();
            return false;
          },
          child: Consumer(builder: (context, ref, _) {
            final commentsValue =
                ref.watch(userCommentsStreamProvider(user.id));
            const playerPadding = EdgeInsets.only(bottom: Player.height);
            return commentsValue.when(
              loading: () => EmptyScreen.loading(padding: playerPadding),
              error: (e, _) => EmptyScreen.text(
                'There was an error displaying the user information.',
                padding: playerPadding,
              ),
              data: (comments) => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: scrollController,
                slivers: [
                  //* Sliver app bar
                  ProfileSliverHeader(
                    user: user,
                    minHeight: minHeight,
                    maxHeight: maxHeight,
                  ),

                  //* Favorite podcasts (horizontal scroll)
                  if (user.favPodcastIds.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '${user.name.split(' ')[0]}\'s Favorite Podcasts',
                              style: context.textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 64,
                            child: ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: user.favPodcastIds.length,
                              separatorBuilder: (context, i) =>
                                  const SizedBox(width: 16),
                              itemBuilder: (context, i) {
                                return Consumer(
                                  builder: (context, ref, _) {
                                    final podcastId = user.favPodcastIds[i];
                                    final podcastValue = ref.watch(
                                        podcastFutureProvider(podcastId));
                                    return podcastValue.when(
                                      loading: () =>
                                          const SkeletonPodcastAvatar(),
                                      error: (e, _) => const SizedBox.shrink(),
                                      data: (podcast) => PodcastAvatar(
                                        podcastId: podcast.id,
                                        imageUrl: podcast.imageUrl,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  //* List of comments
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final comment = comments[i];
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
                    ),
                  ),

                  // so it doesnt end behind the bottom bar
                  const SliverToBoxAdapter(
                      child: SizedBox(height: Player.height)),
                ],
              ),
            );
          }),
        ),
        floatingActionButton: isCurrentUser ? null : ProfileFollowFab(user),
        bottomNavigationBar: const Player(),
      ),
    );
  }
}
