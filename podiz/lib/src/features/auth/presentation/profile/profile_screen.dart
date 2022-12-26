import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/common_widgets/empty_screen.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/grouped_comments.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/auth/presentation/profile/profile_follow_fab.dart';
import 'package:podiz/src/features/auth/presentation/profile/profile_sliver_header.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/skeleton_podcast_avatar.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/player.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/context_theme.dart';

import 'empty_profile.dart';

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
      loading: () => Scaffold(
        appBar: const GradientBar(
          automaticallyImplyLeading: false,
          title: BackTextButton(),
        ),
        body: EmptyScreen.loading(),
      ),
      error: (e, _) => Scaffold(
        appBar: const GradientBar(
          automaticallyImplyLeading: false,
          title: BackTextButton(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: EmptyScreen.text(
            'There was an error opening this profile.',
          ),
        ),
      ),
      data: (user) {
        final child = NotificationListener<ScrollEndNotification>(
          onNotification: (_) {
            snapHeader();
            return false;
          },
          child: CustomScrollView(
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
              if (user.favPodcasts.isNotEmpty)
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
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: user.favPodcasts.length,
                          itemBuilder: (context, i) {
                            return Consumer(
                              builder: (context, ref, _) {
                                final podcastId = user.favPodcasts[i];
                                final podcastValue =
                                    ref.watch(podcastFutureProvider(podcastId));
                                const padding = EdgeInsets.only(right: 16);

                                return podcastValue.when(
                                  loading: () => const Padding(
                                    padding: padding,
                                    child: SkeletonPodcastAvatar(),
                                  ),
                                  error: (e, _) => const SizedBox.shrink(),
                                  data: (podcast) => Padding(
                                    padding: padding,
                                    child: PodcastAvatar(
                                      imageUrl: podcast.imageUrl,
                                      onTap: () => context.pushNamed(
                                        AppRoute.podcast.name,
                                        params: {'podcastId': podcast.id},
                                      ),
                                    ),
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
              Consumer(
                builder: (context, ref, _) {
                  final commentsValue =
                      ref.watch(userCommentsStreamProvider(user.id));
                  final isPlayerAlive =
                      ref.watch(playerStateChangesProvider).valueOrNull != null;
                  return commentsValue.when(
                    loading: () => SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: EmptyScreen.loading(),
                      ),
                    ),
                    error: (e, _) => SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: EmptyScreen.text(
                          'There was an error loading the comments.',
                        ),
                      ),
                    ),
                    data: (comments) {
                      final episodeIds =
                          comments.map((comment) => comment.episodeId).toSet();

                      return comments.isEmpty
                          ? SliverToBoxAdapter(
                              child: EmptyProfile(name: user.name),
                            )
                          : SliverList(
                              delegate: SliverChildListDelegate([
                                for (final episodeId in episodeIds)
                                  GroupedComments(
                                    episodeId,
                                    comments
                                        .where((c) => c.episodeId == episodeId)
                                        .toList(),
                                  )
                              ]),
                            );
                    },
                  );
                },
              ),

              // so it doesnt end behind the bottom bar
              SliverToBoxAdapter(
                  child: SizedBox(
                      height:
                          Player.heightWithSpotify + (isCurrentUser ? 0 : 80))),
            ],
          ),
        );
        return Scaffold(
          extendBody: true,
          body: isCurrentUser
              ? RefreshIndicator(
                  onRefresh: () => ref
                      .read(podcastRepositoryProvider)
                      .refetchFavoritePodcasts(user.id),
                  child: child,
                )
              : child,
          floatingActionButton: isCurrentUser ? null : ProfileFollowFab(user),
          bottomNavigationBar: const Player(extraBottomPadding: true),
        );
      },
    );
  }
}
