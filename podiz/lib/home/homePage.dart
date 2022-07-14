import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/tapTo.dart';
import 'package:podiz/player/playerWidget.dart';
import 'package:podiz/home/feed/feedPage.dart';
import 'package:podiz/home/notifications/NotificationsPage.dart';
import 'package:podiz/home/search/searchPage.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

mixin HomePageMixin on Widget {
  String get label;
  Widget get icon;
  Widget get activeIcon;
}

class HomePage extends ConsumerStatefulWidget {
  static const route = '/home';
  UserPodiz user;

  HomePage(this.user);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {

  var pageIndex = 0;
  final pageController = PageController(initialPage: 0);
  bool isPlaying = false;

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
    List<HomePageMixin> pages = <HomePageMixin>[
      FeedPage(isPlaying, user: widget.user,),
      SearchPage(),
      NotificationsPage(isPlaying),
    ];
    final player = ref.watch(playerStreamProvider);
    return player.maybeWhen(
        orElse: () => SplashScreen.error(),
        loading: () => SplashScreen(),
        data: (p) {
          p.playingState == PlayerState.close
              ? isPlaying = false
              : isPlaying = true;
          return KeyboardVisibilityBuilder(
            builder: (context, isKeyBoardOpen) {
              return Scaffold(
                body: SafeArea(
                  child: TapTo.unfocus(
                    child: Stack(
                      children: [
                        PageView(
                          controller: pageController,
                          onPageChanged: (i) => setState(() {
                            pageIndex = i;
                          }),
                          children: pages,
                        ),
                        !isKeyBoardOpen
                            ? p.playingState != PlayerState.close
                                ? Positioned(
                                    right: 0,
                                    left: 0,
                                    bottom: 93,
                                    child: PlayerWidget(p))
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
                                          unselectedItemColor:
                                              Color(0xB2FFFFFF),
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
            },
          );
        });
  }
}
