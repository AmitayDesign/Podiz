import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/shimmerLoading.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/home/components/replyView.dart';
import 'package:podiz/home/feed/components/buttonPlay.dart';
import 'package:podiz/home/feed/components/cardButton.dart';
import 'package:podiz/home/feed/components/podcastListTileQuickNote.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/loading.dart/notificationLoading.dart';
import 'package:podiz/loading.dart/shimmerContainer.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/NotificationPodiz.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/player/components/discussionCard.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/home/notifications/components/tabBarLabel.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/onboarding/components/linearGradientAppBar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/profile/userManager.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class NotificationsPage extends ConsumerStatefulWidget with HomePageMixin {
  @override
  final String label = 'Notifications';
  @override
  final Widget icon = const Icon(Icons.notifications);
  @override
  final Widget activeIcon = const Icon(Icons.notifications);

  static const route = '/profile';

  bool isPlaying;
  NotificationsPage(this.isPlaying, {Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controllerText;
  late FocusNode _focusNode;

  bool visible = false;
  Comment? commentToReply;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controllerText = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  final _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    // return Container();
    final theme = Theme.of(context);
    final notifications = ref.watch(notificationsStreamProvider);
    return notifications.maybeWhen(
        loading: () => notificationsShimmerLoading(context),
        orElse: () => SplashScreen.error(),
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
                            : SizedBox(height: widget.isPlaying ? 205 : 101),
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
                          : SizedBox(height: widget.isPlaying ? 205 : 101),
                    )),
          );
          return GestureDetector(
            onTap: () {
              _focusNode.unfocus();
              setState(() {
                visible = false;
              });
            },
            child: Stack(children: [
              Align(
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
                                labelStyle: notificationsSelectedLabel(),
                                unselectedLabelStyle:
                                    notificationsUnselectedLabel(),
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
                        padding: EdgeInsets.only(top: 20),
                        child: TabBarView(children: children),
                      ),
                    ),
                  )),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: visible ? replyView() : Container(),
              )
            ]),
          );
        });
  }

  Widget _buildItem(Comment c) {
    final theme = Theme.of(context);

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
                  style: TextStyle(fontSize: 18),
                ),
              );

              // if we got our data
            } else if (snapshot.hasData) {
              final user = snapshot.data as UserPodiz;
              return FutureBuilder(
                  future: ref
                      .read(podcastManagerProvider)
                      .getPodcastFromFirebase(c.episodeUid),
                  initialData: "loading",
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // If we got an error
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            '${snapshot.error} occurred',
                            style: TextStyle(fontSize: 18),
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
                                  LimitedBox(
                                    maxWidth: kScreenWidth - (16 + 8 + 32 + 16),
                                    maxHeight: 40,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            podcast.name,
                                            style: discussionCardProfile(),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(podcast.show_name,
                                                style:
                                                    discussionAppBarInsights())),
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
                                        CircleProfile(user: user, size: 20),
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
                                                      discussionCardProfile(),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      "${user.followers.length} followers",
                                                      style:
                                                          discussionCardFollowers())),
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
                                        style: discussionCardComment(),
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
                                                onTap: () {
                                                  setState(() {
                                                    visible = true;
                                                    commentToReply = c;
                                                  });
                                                  _focusNode.requestFocus();
                                                },
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
                                                          style:
                                                              discussionSnackCommentHint(),
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                              const Spacer(),
                                              CardButton(
                                                const Icon(
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

  Widget replyView() {
    return FutureBuilder(
      future:
          ref.read(userManagerProvider).getUserFromUid(commentToReply!.userUid),
      initialData: "loading",
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If we got an error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error} occurred',
                style: TextStyle(fontSize: 18),
              ),
            );

            // if we got our data
          } else if (snapshot.hasData) {
            final user = snapshot.data as UserPodiz;
            return Container(
              width: kScreenWidth,
              decoration: const BoxDecoration(
                color: Color(0xFF4E4E4E),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Replying to...",
                        style: podcastInsightsQuickNote(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleProfile(user: user, size: 20),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            Text(
                              user.name,
                              style: discussionCardProfile(),
                            ),
                            Text("${user.followers.length} Followers",
                                style: discussionCardFollowers()),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(commentToReply!.comment,
                            style: discussionCardComment())),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleProfile(user: user, size: 15.5),
                        const SizedBox(width: 8),
                        LimitedBox(
                          maxWidth: kScreenWidth - (14 + 31 + 8 + 31 + 8 + 14),
                          maxHeight: 31,
                          child: TextField(
                            // key: _key,
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            focusNode: _focusNode,
                            controller: _controllerText,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF262626),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              hintStyle: discussionSnackCommentHint(),
                              hintText: "Comment on ${user.name} insight...",
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            ref
                                .read(authManagerProvider)
                                .doReply(commentToReply!, _controllerText.text);
                            setState(() {
                              visible = false;
                              commentToReply = null;
                              _controllerText.clear();
                            });
                          },
                          child: Container(
                            height: 31,
                            width: 31,
                            decoration: BoxDecoration(
                              color: Palette.darkPurple,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.send,
                              size: 11,
                              color: Palette.pureWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            );
          }
        }
        return Container(
          width: kScreenWidth,
          height: 50,
          decoration: const BoxDecoration(
            color: Color(0xFF4E4E4E),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget notificationsShimmerLoading(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: const [
        NotificationLoading(),
        SizedBox(height: 12),
        NotificationLoading(),
        SizedBox(height: 12),
        NotificationLoading(),
        SizedBox(height: 12),
      ],
    );
  }
}
