import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/widgets/appBarGradient.dart';
import 'package:podiz/aspect/widgets/buttonPlay.dart';
import 'package:podiz/aspect/widgets/cardButton.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/home/components/profileAvatar.dart';
import 'package:podiz/home/components/replyView.dart';
import 'package:podiz/home/notifications/components/tabBarLabel.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/loading.dart/notificationLoading.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/NotificationPodiz.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/profile/userManager.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

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

  final _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlaying = ref.watch(playerStreamProvider).valueOrNull?.getState ==
        PlayerState.play;
    final notifications = ref.watch(notificationsStreamProvider);
    return notifications.when(
        loading: () => const NotificationLoading(),
        error: (e, _) {
          print('notificationPage: ${e.toString()}');
          return SplashScreen.error();
        },
        data: (n) {
          Iterable<String> keys = n.keys;

          int number = keys.length;

          List<Widget> tabs = [];
          List<Widget> children = [];

          int numberValue;

          for (String key in keys) {
            print(key);
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
    // return Container();
    return FutureBuilder(
        future: ref.read(userManagerProvider).getUserFromUid(c.userUid),
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
              return FutureBuilder(
                  future: ref
                      .read(podcastManagerProvider)
                      .fetchPodcast(c.episodeUid),
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
                        podcast.uid = c.episodeUid;
                        return Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  PodcastAvatar(
                                      imageUrl: podcast.image_url, size: 32),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            podcast.name,
                                            style:
                                                context.textTheme.titleMedium,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            podcast.show_name,
                                            style: context.textTheme.bodyMedium!
                                                .copyWith(
                                              color: Colors.white70,
                                            ),
                                            overflow: TextOverflow.ellipsis,
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
                                                  style: context
                                                      .textTheme.titleMedium,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                        ButtonPlay(podcast, c.time),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              InkWell(
                                                onTap: () =>
                                                    showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
                                                        backgroundColor:
                                                            Palette.grey900,
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .vertical(
                                                            top: Radius.circular(
                                                                kBorderRadius),
                                                          ),
                                                        ),
                                                        builder: (context) =>
                                                            Padding(
                                                              padding: MediaQuery
                                                                      .of(context)
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
                                                          BorderRadius.circular(
                                                              30),
                                                      color: Palette.grey900,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          "Comment on ${user.name} insight...",
                                                          style: context
                                                              .textTheme
                                                              .bodySmall,
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
                      }
                    }
                    return const NotificationLoading();
                  });
            }
          }
          return const NotificationLoading();
        });
  }
}
