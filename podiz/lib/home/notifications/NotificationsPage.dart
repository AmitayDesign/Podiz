import 'package:flutter/material.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/feed/components/podcastListTileQuickNote.dart';
import 'package:podiz/player/components/discussionCard.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/home/notifications/components/tabBarLabel.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/onboarding/components/linearGradientAppBar.dart';
import 'package:podiz/profile/components.dart/commentCard.dart';
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
    return Container();
    // final theme = Theme.of(context);
    // final notifications = ref.watch(notificationsStreamProvider);
    // return notifications.maybeWhen(
    //     loading: () => CircularProgressIndicator(),
    //     orElse: () => SplashScreen.error(),
    //     data: (n) {
    //       Iterable<String> keys = n.keys;
    //       int number = keys.length + 1;

    //       List<Widget> tabs = [];
    //       List<Widget> children = [];

    //       int count = 0;
    //       int numberValue;

    //       for (String key in keys) {
    //         numberValue = n[key]!.length;
    //         tabs.add(TabBarLabel(key, numberValue));
    //         children.add(ListView.builder(
    //                     controller: _controller,
    //                     itemCount: podcasts.length + 1,
    //                     itemBuilder: (context, index) => Padding(
    //                           padding: const EdgeInsets.only(top: 17.0),
    //                           child: (index != podcasts.length)
    //                               ? DiscussionCard(c)
    //                               : SizedBox(
    //                                   height: widget.isPlaying ? 205 : 101),
    //                         )),)
    //         count += numberValue;
    //       }
    //       tabs.insert(0, TabBarLabel("All", count));

    //       return Align(
    //         alignment: Alignment.centerLeft,
    //         child: NestedScrollView(
    //           headerSliverBuilder: (context, value) {
    //             return [
    //               SliverAppBar(
    //                 automaticallyImplyLeading: false,
    //                 flexibleSpace: Container(
    //                   height: 96,
    //                   decoration: BoxDecoration(
    //                     gradient: appBarGradient(),
    //                   ),
    //                 ),
    //                 bottom: TabBar(
    //                     isScrollable: true,
    //                     controller: _tabController,
    //                     labelStyle: notificationsSelectedLabel(),
    //                     unselectedLabelStyle: notificationsUnselectedLabel(),
    //                     indicatorSize: TabBarIndicatorSize.tab,
    //                     overlayColor:
    //                         MaterialStateProperty.all(const Color(0xFF262626)),
    //                     indicator: BoxDecoration(
    //                       borderRadius: BorderRadius.circular(50),
    //                       color: theme.primaryColor,
    //                     ),
    //                     padding: const EdgeInsets.only(left: 16),
    //                     tabs: tabs),
    //               )
    //             ];
    //           },
    //           body: Padding(
    //             padding: EdgeInsets.only(top: 20),
    //             child: TabBarView(
    //               controller: _tabController,
    //               children: children))

    //             ),
    //           ),
    //         ),
    //       );
    //     });
  }
}
