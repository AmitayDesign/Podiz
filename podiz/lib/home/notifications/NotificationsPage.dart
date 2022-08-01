import 'package:flutter/material.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/feed/components/podcastListTileQuickNote.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/objects/user/NotificationPodiz.dart';
import 'package:podiz/player/components/discussionCard.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/home/notifications/components/tabBarLabel.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/onboarding/components/linearGradientAppBar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    // return Container();
    final theme = Theme.of(context);
    final notifications = ref.watch(notificationsStreamProvider);
    return notifications.maybeWhen(
        loading: () => CircularProgressIndicator(),
        orElse: () => SplashScreen.error(),
        data: (n) {
          Iterable<String> keys = n.keys;
          // int number = keys.length + 1;
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
                            ? DiscussionCard(
                                ref
                                    .read(podcastManagerProvider)
                                    .getPodcastById(n[key]![index].episodeUid)
                                    .searchResultToPodcast(),
                                n[key]![index].notificationToComment())
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
                          ? DiscussionCard(
                              ref
                                  .read(podcastManagerProvider)
                                  .getPodcastById(list[index].episodeUid)
                                  .searchResultToPodcast(),
                              list[index].notificationToComment())
                          : SizedBox(height: widget.isPlaying ? 205 : 101),
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
              ));
        });
  }
}
