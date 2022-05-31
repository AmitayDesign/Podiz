import 'package:flutter/material.dart';
import 'package:podiz/home/components/HomeAppBar.dart';
import 'package:podiz/home/feed/feedPage.dart';
import 'package:podiz/home/profile/ProfilePage.dart';
import 'package:podiz/home/search/searchPage.dart';

mixin HomePageMixin on Widget {
  String get label;
  Widget get icon;
  Widget get activeIcon;
}

class HomePage extends StatefulWidget {
  static const route = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  //
  updateAppBar(String title) {
    setState(() {
      title = title;
    });
  }

  var pageIndex = 0;
  final pageController = PageController(initialPage: 0);
  String title = "";
  final pages = <HomePageMixin>[
    FeedPage(),
    SearchPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void changeTab(int index) => pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 250),
        curve: Curves.ease,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: pageController,
          onPageChanged: (i) => setState(() {
            pageIndex = i;
            title = "";
          }),
          children: pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: changeTab,
        items: pages.map((page) {
          return BottomNavigationBarItem(
            icon: page.icon,
            activeIcon: page.activeIcon,
            label: page.label,
          );
        }).toList(),
      ),
    );
  }
}
