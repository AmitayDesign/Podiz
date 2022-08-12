import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/widgets/buttonPlay.dart';
import 'package:podiz/aspect/widgets/cardButton.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/home/components/profileAvatar.dart';
import 'package:podiz/home/components/replyView.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/loading.dart/notificationLoading.dart';
import 'package:podiz/loading.dart/shimmerContainer.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/show.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/profile/components.dart/backAppBar.dart';
import 'package:podiz/profile/components.dart/followPeopleButton.dart';
import 'package:podiz/profile/userManager.dart';
import 'package:podiz/providers.dart';

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

  void openShow(Podcast podcast) {
    context.goNamed(
      AppRoute.show.name,
      params: {'showId': podcast.show_uri},
    );
  }

  void openShowFavourite(Show show) {
    context.goNamed(
      AppRoute.show.name,
      params: {'showId': show.uid!},
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userValue = currentUser.uid == widget.userId
        ? AsyncData(currentUser)
        : ref.watch(userProvider(widget.userId));

    return userValue.when(
        error: (e, _) => Text(e.toString()),
        loading: () =>
            const Center(child: CircularProgressIndicator()), //TODO shimmer?
        data: (user) {
          return Scaffold(
            appBar: BackAppBar(),
            body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(user.image_url),
                        radius: 50,
                      ),
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

                    user.favPodcasts.isNotEmpty
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
                    user.favPodcasts.isNotEmpty
                        ? SizedBox(
                            height: 68,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: user.favPodcasts.map((show) {
                                return _buildFavouriteItem(show);
                              }).toList(),
                            ),
                          )
                        : Container() //change this
                  ],
                ),
              ),
              const SizedBox(height: 54),
              user.comments.isNotEmpty
                  ? Expanded(
                      child: ListView(
                        children: user.comments.reversed
                            .map((c) => _buildItem(
                                user, c)) //change this to notifications
                            .toList(),
                      ),
                    )
                  : Container() //change this
            ]),
            floatingActionButton:
                currentUser.uid == user.uid ? null : followPeopleButton(user),
          );
        });
  }

  Widget _buildFavouriteItem(String showUid) {
    return FutureBuilder(
        future: ref.read(showManagerProvider).fetchShow(showUid),
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
              final show = snapshot.data as Show;
              return InkWell(
                onTap: () => openShowFavourite(show),
                child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: PodcastAvatar(imageUrl: show.image_url, size: 68)),
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
    return FutureBuilder(
        future: ref.read(podcastManagerProvider).fetchPodcast(c.episodeUid),
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
              final episode = snapshot.data as Podcast;
              episode.uid = c.episodeUid;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        PodcastAvatar(imageUrl: episode.image_url, size: 32),
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
                                  onTap: () => openShow(episode),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      episode.show_name,
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
                              ProfileAvatar(user: user, radius: 20),
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
                              const Spacer(),
                              ButtonPlay(episode, c.time),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: kScreenWidth - 32,
                            child: Text(
                              c.comment,
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
            }
          }
          return const NotificationLoading();
        });
  }
}
