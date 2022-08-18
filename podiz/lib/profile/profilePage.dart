import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/cardButton.dart';
import 'package:podiz/home/components/replyView.dart';
import 'package:podiz/loading.dart/notificationLoading.dart';
import 'package:podiz/loading.dart/shimmerContainer.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/data/podcast_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/domain/podcast.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/features/podcast/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/palette.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final String userId;
  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  void openPodcast(Episode episode) {
    context.goNamed(
      AppRoute.podcast.name,
      params: {'podcastId': episode.showId},
    );
  }

  void openShowFavourite(Podcast podcast) {
    context.goNamed(
      AppRoute.podcast.name,
      params: {'podcastId': podcast.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userValue = currentUser.id == widget.userId
        ? AsyncData(currentUser)
        : ref.watch(userProvider(widget.userId));

    return userValue.when(
        error: (e, _) => Text(e.toString()),
        loading: () =>
            const Center(child: CircularProgressIndicator()), //TODO shimmer?
        data: (user) {
          return Scaffold(
            appBar: const GradientBar(
              automaticallyImplyLeading: false,
              title: BackTextButton(),
            ),
            body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: UserAvatar(user: user, radius: 50),
                    ),

                    const SizedBox(height: 12),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          user.name,
                          style: context.textTheme.titleLarge,
                        )),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          user.followers.length.toString(),
                          style: context.textTheme.titleLarge!.copyWith(
                            color: Palette.white90,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Followers",
                          style: context.textTheme.bodyLarge!.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          user.following.length.toString(),
                          style: context.textTheme.titleLarge!.copyWith(
                            color: Palette.white90,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Following",
                          style: context.textTheme.bodyLarge!.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                    user.favPodcastIds.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: SizedBox(
                              width: kScreenWidth,
                              child: Text(
                                "${user.name.split(" ")[0]}'s Favorite Podcasts",
                                textAlign: TextAlign.left,
                                style: context.textTheme.titleSmall,
                              ),
                            ),
                          )
                        : Container(),
                    const SizedBox(height: 8),
                    user.favPodcastIds.isNotEmpty
                        ? SizedBox(
                            height: 68,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: user.favPodcastIds.map((show) {
                                return _buildFavouriteItem(show);
                              }).toList(),
                            ),
                          )
                        : Container() //change this
                  ],
                ),
              ),
              const SizedBox(height: 54),
              // user.comments.isNotEmpty
              //     ? Expanded(
              //         child: ListView(
              //           children: user.comments.reversed
              //               .map((c) => _buildItem(
              //                   user, c)) //change this to notifications
              //               .toList(),
              //         ),
              //       )
              //     : Container() //change this
            ]),
            // floatingActionButton:
            //     currentUser.id == user.id ? null : followPeopleButton(user),
          );
        });
  }

  Widget _buildFavouriteItem(String showUid) {
    return FutureBuilder(
        future: ref.read(podcastRepositoryProvider).fetchPodcast(showUid),
        initialData: "loading",
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If we got an error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error} occurred',
                  style: const TextStyle(fontSize: 18),
                ),
              );

              // if we got our data
            } else if (snapshot.hasData) {
              final podcast = snapshot.data as Podcast;
              return InkWell(
                onTap: () => openShowFavourite(podcast),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: PodcastAvatar(
                    podcastId: podcast.id,
                    imageUrl: podcast.imageUrl,
                    size: 68,
                  ),
                ),
              );
            }
          }
          return const Padding(
            padding: EdgeInsets.only(right: 16),
            child: ShimmerContainer(width: 68, height: 68, borderRadius: 20),
          );
        });
  }

  Widget _buildItem(UserPodiz user, Comment c) {
    final theme = Theme.of(context);
    final playerRepository = ref.watch(playerRepositoryProvider);
    return Consumer(
      builder: (context, ref, _) {
        final episodeValue = ref.read(episodeFutureProvider(c.episodeId));

        return episodeValue.when(
            loading: () => const NotificationLoading(),
            error: (e, _) => Center(
                  child: Text(
                    '$e occurred',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
            data: (episode) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        PodcastAvatar(
                          podcastId: episode.showId,
                          imageUrl: episode.imageUrl,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    episode.name,
                                    style: context.textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => openPodcast(episode),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      episode.showName,
                                      style: context.textTheme.bodyMedium!
                                          .copyWith(
                                        color: Colors.white70,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    color: theme.colorScheme.surface,
                    width: kScreenWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14.0, vertical: 9),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              UserAvatar(user: user, radius: 20),
                              const SizedBox(
                                width: 8,
                              ),
                              SizedBox(
                                width: 200,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        user.name,
                                        style: context.textTheme.titleMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "${user.followers.length} followers",
                                        style: context.textTheme.bodyMedium!
                                            .copyWith(
                                          color: Palette.grey600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TimeChip(
                                icon: Icons.play_arrow,
                                position: c.time,
                                onTap: () => playerRepository.play(
                                    episode.id, c.time ~/ 1000 - 10), //!
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: kScreenWidth - 32,
                            child: Text(
                              c.text,
                              style: context.textTheme.bodyLarge,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const SizedBox(height: 12),
                          c.lvl == 4
                              ? Container()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () => showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Palette.grey900,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(
                                                  kBorderRadius),
                                            ),
                                          ),
                                          builder: (context) => Padding(
                                                padding: MediaQuery.of(context)
                                                    .viewInsets,
                                                child: ReplyView(
                                                    comment: c, user: user),
                                              )),
                                      child: Container(
                                          width: kScreenWidth -
                                              (16 + 20 + 16 + 16),
                                          height: 33,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Palette.grey900,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                  "Comment on ${user.name} insight...",
                                                  style: context
                                                      .textTheme.bodySmall),
                                            ),
                                          )),
                                    ),
                                    const Spacer(),
                                    const CardButton(
                                      Icon(
                                        Icons.share,
                                        color: Color(0xFF9E9E9E),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            });
      },
    );
  }
}
