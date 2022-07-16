import 'package:flutter/material.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/feed/components/podcastListTileQuickNote.dart';
import 'package:podiz/player/components/discussionCard.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/home/notifications/components/tabBarLabel.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/onboarding/components/linearGradientAppBar.dart';
import 'package:podiz/profile/components.dart/commentCard.dart';

class NotificationsPage extends StatefulWidget with HomePageMixin {
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
  Comment c = Comment("id",
      uid: "spotify:episode:00bf3aQMbuhOGvH2GqOw5w",
      timestamp: DateTime.now().toIso8601String(),
      comment: "DENGUE DENGUE DENGUE",
      time: 123521);
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
                itemCount: podcasts.length + 1,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: (index != podcasts.length)
                      ? CommentCard(c)
                      : SizedBox(height: widget.isPlaying ? 205 : 101),
                ),
              ),
              ListView.builder(
                  controller: _controller,
                  itemCount: podcasts.length + 1,
                  itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(top: 17.0),
                        child: (index != podcasts.length)
                            ? DiscussionCard(c)
                            : SizedBox(height: widget.isPlaying ? 205 : 101),
                      )),
              ListView.builder(
                  controller: _controller,
                  itemCount: podcasts.length + 1,
                  itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(top: 17.0),
                        child: (index != podcasts.length)
                            ? DiscussionCard(c)
                            : SizedBox(height: widget.isPlaying ? 205 : 101),
                      )),
              ListView.builder(
                  controller: _controller,
                  itemCount: podcasts.length + 1,
                  itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(top: 17.0),
                        child: (index != podcasts.length)
                            ? DiscussionCard(c)
                            : SizedBox(height: widget.isPlaying ? 205 : 101),
                      )),
            ],
          ),
        ),
      ),
    );
  }
}
