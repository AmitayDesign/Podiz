import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/appBarGradient.dart';
import 'package:podiz/aspect/widgets/cardButton.dart';
import 'package:podiz/home/components/replyView.dart';
import 'package:podiz/home/notifications/components/tabBarLabel.dart';
import 'package:podiz/loading.dart/notificationLoading.dart';
import 'package:podiz/objects/user/NotificationPodiz.dart';
import 'package:podiz/profile/userManager.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/src/common_widgets/splash_screen.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/presentation/time_chip.dart';
import 'package:podiz/src/features/podcast/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/palette.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void openShow(Episode episode) {
    context.goNamed(
      AppRoute.show.name,
      params: {'showId': episode.showId},
    );
  }

  final _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlaying =
        ref.watch(playerStateChangesProvider).valueOrNull?.isPlaying ?? false;
    final notifications = ref.watch(notificationsStreamProvider);
    return notifications.when(
        loading: () => const NotificationLoading(),
        error: (e, _) {
          print('notificationPage: ${e.toString()}');
          return const SplashScreen.error();
        },
        data: (n) {
          Iterable<String> keys = n.keys;

          int number = keys.length;

          List<Widget> tabs = [];
          List<Widget> children = [];

          int numberValue;

          for (String key in keys) {
            numberValue = n[key]!.length;
            tabs.add(TabBarLabel(key, numberValue));
            children.add(
              ListView.builder(
                  controller: _controller,
                  itemCount: numberValue + 1,
                  itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(top: 17.0),
                        child: (index != numberValue)
                            ? _buildItem(n[key]![index].notificationToComment())
                            : SizedBox(height: isPlaying ? 205 : 101),
                      )),
            );
          }
          List<NotificationPodiz> list = [];
          n.forEach((key, value) => list.addAll(value));

          tabs.insert(0, TabBarLabel("All", list.length));
          children.insert(
            0,
            ListView.builder(
                controller: _controller,
                itemCount: list.length + 1,
                itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(top: 17.0),
                      child: (index != list.length)
                          ? _buildItem(list[index].notificationToComment())
                          : SizedBox(height: isPlaying ? 205 : 101),
                    )),
          );
          return Align(
            alignment: Alignment.centerLeft,
            child: DefaultTabController(
              length: number + 1,
              child: NestedScrollView(
                headerSliverBuilder: (context, value) {
                  return [
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      flexibleSpace: Container(
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: appBarGradient(),
                        ),
                      ),
                      bottom: TabBar(
                          isScrollable: true,
                          labelStyle: context.textTheme.titleMedium!.copyWith(
                            color: Palette.white90,
                          ),
                          unselectedLabelStyle:
                              context.textTheme.bodyLarge!.copyWith(
                            color: Colors.white70,
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          overlayColor: MaterialStateProperty.all(
                              const Color(0xFF262626)),
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: theme.primaryColor,
                          ),
                          padding: const EdgeInsets.only(left: 16),
                          tabs: tabs),
                    )
                  ];
                },
                body: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TabBarView(children: children),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildItem(Comment c) {
    final theme = Theme.of(context);
    final playerRepository = ref.watch(playerRepositoryProvider);
    // return Container();
    return FutureBuilder(
        future: ref.read(userManagerProvider).getUserFromUid(c.userId),
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
              final user = snapshot.data as UserPodiz;
              final episodeValue = ref.read(episodeFutureProvider(c.episodeId));
              return episodeValue.when(
                  error: (e, _) => Center(
                        child: Text(
                          '${snapshot.error} occurred',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                  loading: () => const NotificationLoading(),
                  data: (episode) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              PodcastAvatar(
                                  imageUrl: episode.imageUrl, size: 32),
                              const SizedBox(width: 8),
                              Expanded(
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
                                    const SizedBox(height: 2),
                                    GestureDetector(
                                      onTap: () => openShow(episode),
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
                                              style:
                                                  context.textTheme.titleMedium,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "${user.followers.length} followers",
                                              style: context
                                                  .textTheme.bodyMedium!
                                                  .copyWith(
                                                color: Palette.grey600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    TimeChip(
                                      icon: Icons.play_arrow,
                                      position: c.time,
                                      onTap: () => playerRepository.play(
                                          episode.id, c.time - 10000), //!
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: () => showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Palette.grey900,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(
                                                        kBorderRadius),
                                                  ),
                                                ),
                                                builder: (context) => Padding(
                                                      padding:
                                                          MediaQuery.of(context)
                                                              .viewInsets,
                                                      child: ReplyView(
                                                          comment: c,
                                                          user: user),
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Comment on ${user.name} insight...",
                                                      style: context
                                                          .textTheme.bodySmall,
                                                    ),
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
            }
          }
          return const NotificationLoading();
        });
  }
}
