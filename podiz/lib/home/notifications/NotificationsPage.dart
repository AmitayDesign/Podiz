import 'package:flutter/material.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/podcastListTileQuickNote.dart';
import 'package:podiz/home/feed/components/discussionCard.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/home/notifications/components/tabBarLabel.dart';
import 'package:podiz/onboarding/components/linearGradientAppBar.dart';
import 'package:podiz/profile/components.dart/followersCard.dart';

class NotificationsPage extends StatefulWidget with HomePageMixin {
  @override
  final String label = 'Notifications';
  @override
  final Widget icon = const Icon(Icons.notifications);
  @override
  final Widget activeIcon = const Icon(Icons.notifications);

  static const route = '/profile';
  NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    _tabController!.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
    _controller.dispose();
  }

  final _controller = ScrollController();
  List<String> podcasts = ["1", "2", "3"];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
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
                controller: _tabController,
                labelStyle: notificationsSelectedLabel(),
                unselectedLabelStyle: notificationsUnselectedLabel(),
                indicatorSize: TabBarIndicatorSize.tab,
                overlayColor:
                    MaterialStateProperty.all(const Color(0xFF262626)),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: theme.primaryColor,
                ),
                padding: const EdgeInsets.only(left: 16),
                tabs: [
                  TabBarLabel("All", 34),
                  TabBarLabel("Is It Time For M...", 12),
                  TabBarLabel("Is It Time For M...", 12),
                  TabBarLabel("Is It Time For M...", 10),
                ],
              ),
            )
          ];
        },
        body: Padding(
          padding: EdgeInsets.only(top: 20),
          child: TabBarView(
            controller: _tabController,
            children: [
              ListView.builder(
                  controller: _controller,
                  itemCount: podcasts.length,
                  itemBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: FollowersCard(),
                      )),
              ListView.builder(
                  controller: _controller,
                  itemCount: podcasts.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(top: 17.0),
                    child: DiscussionCard(),
                  )),
              ListView.builder(
                  controller: _controller,
                  itemCount: podcasts.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(top: 17.0),
                    child: DiscussionCard(),
                  )),
              ListView.builder(
                  controller: _controller,
                  itemCount: podcasts.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(top: 17.0),
                    child: DiscussionCard(),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
