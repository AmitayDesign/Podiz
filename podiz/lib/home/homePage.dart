import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/tapTo.dart';
import 'package:podiz/home/components/player.dart';
import 'package:podiz/home/feed/feedPage.dart';
import 'package:podiz/home/notifications/NotificationsPage.dart';
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
  bool player = true;

  final pages = <HomePageMixin>[
    FeedPage(),
    SearchPage(),
    NotificationsPage(),
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void changeTab(int index) => pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.ease,
      );

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyBoardOpen) {
      return Scaffold(
        body: SafeArea(
          child: TapTo.unfocus(
            child: Stack(
              children: [
                PageView(
                  controller: pageController,
                  onPageChanged: (i) => setState(() {
                    pageIndex = i;
                    title = "";
                  }),
                  children: pages,
                ),
                !isKeyBoardOpen
                    ? player
                        ? Positioned(
                            right: 0, left: 0, bottom: 93, child: Player())
                        : Container()
                    : Container(),
                !isKeyBoardOpen
                    ? Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: SizedBox(
                          height: 93,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 5,
                                sigmaY: 10,
                              ),
                              child: Opacity(
                                opacity: 0.9,
                                child: BottomNavigationBar(
                                  iconSize: 30,
                                  showSelectedLabels: true,
                                  showUnselectedLabels: true,
                                  selectedItemColor: Color(0xFFD74EFF),
                                  unselectedItemColor: Color(0xB2FFFFFF),
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
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
