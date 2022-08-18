import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/splash_screen.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/auth/presentation/profile/profile_follow_fab.dart';
import 'package:podiz/src/features/auth/presentation/profile/profile_sliver_header.dart';
import 'package:podiz/src/features/episodes/avatar/skeleton_podcast_avatar.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/features/player/presentation/player.dart';

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
  double get maxHeight => statusBarHeight + 280;

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
      error: (e, _) => const SplashScreen.error(), //!
      loading: () => const SplashScreen(), //!
      data: (user) => Scaffold(
        extendBody: true,
        body: NotificationListener<ScrollEndNotification>(
          onNotification: (_) {
            snapHeader();
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            slivers: [
              ProfileSliverHeader(
                user: user,
                minHeight: minHeight,
                maxHeight: maxHeight,
              ),
              if (user.favPodcastIds.isNotEmpty)
                CustomScrollView(
                  scrollDirection: Axis.horizontal,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Text(
                        '${user.name.split(' ')[0]}\'s Favorite Podcasts',
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Consumer(
                          builder: (context, ref, _) {
                            final podcastId = user.favPodcastIds[i];
                            final podcastValue =
                                ref.watch(podcastFutureProvider(podcastId));
                            return podcastValue.when(
                              loading: () => const SkeletonPodcastAvatar(),
                              error: (e, _) => const SizedBox.shrink(),
                              data: (podcast) => PodcastAvatar(
                                podcastId: podcast.id,
                                imageUrl: podcast.imageUrl,
                              ),
                            );
                          },
                        ),
                        childCount: user.favPodcastIds.length,
                      ),
                    ),
                  ],
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 48)),
              // SliverList(
              //   delegate: SliverChildBuilderDelegate(
              //     (context, i) => Consumer(
              //       builder: (context, ref, _) {
              //         final podcastId = user.favPodcastIds[i];
              //         final podcastValue =
              //             ref.watch(podcastFutureProvider(podcastId));
              //         return podcastValue.when(
              //           loading: () => const SkeletonPodcastAvatar(),
              //           error: (e, _) => const SizedBox.shrink(),
              //           data: (podcast) => PodcastAvatar(
              //             podcastId: podcast.id,
              //             imageUrl: podcast.imageUrl,
              //           ),
              //         );
              //       },
              //     ),
              //     childCount: user.favPodcastIds.length,
              //   ),
              // ),

              // so it doesnt end behind the bottom bar
              const SliverToBoxAdapter(child: SizedBox(height: Player.height)),
            ],
          ),
        ),
        floatingActionButton: isCurrentUser ? null : ProfileFollowFab(user),
        bottomNavigationBar: const Player(),
      ),
    );
  }
}
