import 'package:flutter/material.dart';
import 'package:podiz/aspect/widgets/preferredAppBar.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/home/profile/components/ProfileTopAppBar.dart';
import 'package:podiz/home/profile/components/tabBarLabel.dart';
import 'package:podiz/objects/user/User.dart';

class ProfilePage extends StatefulWidget with HomePageMixin {
  @override
  final String label = 'Profile';
  @override
  final Widget icon = const Icon(Icons.person);
  @override
  final Widget activeIcon = const Icon(Icons.person, color: Color(0xFF6310BF));

  static const route = '/profile';
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

final UserPodiz user =
    UserPodiz("uid", name: "Amitay", email: "email", timestamp: DateTime.now());

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: true,
              // pinned: true,
              elevation: 0,
              expandedHeight: 380, //TODO check this value
              flexibleSpace: FlexibleSpaceBar(
                background: ProfileTopAppBar(user),
              ),
              bottom: TabBar(
                controller: _tabController,
                // labelStyle: , TODO
                // unselectedLabelStyle: ,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: theme.primaryColor,
                ),
                tabs: [
                  TabBarLabel("feed"),
                  TabBarLabel("saved"),
                ],
              ),
            )
          ];
        },
        body: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: TabBarView(
            controller: _tabController,
            children: [
              Container(
                width: 80,
                height: 80,
                color: Colors.red,
              ),
              Container(
                width: 80,
                height: 80,
                color: Colors.green,
              )
            ],
          ),
        )
        // ]), //TODO put here the pod cast widget

        );
  }
}
