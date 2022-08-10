import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/widgets/tapTo.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/playerWidget.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

enum HomeDestination { feed, search, notifications }

class HomePage extends ConsumerStatefulWidget {
  final HomeDestination? destination;
  const HomePage({Key? key, this.destination}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

/// Use the [AutomaticKeepAliveClientMixin] to keep the state.
class _HomePageState extends ConsumerState<HomePage>
    with AutomaticKeepAliveClientMixin {
  late var destination = widget.destination ?? HomeDestination.feed;
  late final pageController = PageController(initialPage: destination.index);

  bool isPlaying = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      final page = pageController.page;
      if (page != null && page == page.toInt()) goToDestination(page.toInt());
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.destination != null &&
        pageController.hasClients &&
        pageController.position.hasViewportDimension) {
      destination = widget.destination!;
      pageController.animateToPage(
        destination.index,
        duration: kTabScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  void goToDestination(int i) {
    if (i != destination.index) {
      context.goNamed(
        AppRoute.home.name,
        queryParams: {'destination': HomeDestination.values[i].name},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // call 'super.build' when using 'AutomaticKeepAliveClientMixin'
    super.build(context);

    final player = ref.watch(playerStreamProvider);
    return player.when(
        error: (e, _) {
          print(e);
          return SplashScreen.error();
        },
        loading: () => SplashScreen(),
        data: (p) {
          p.getState == PlayerState.close
              ? isPlaying = false
              : isPlaying = true;
          // if (p.error) {
          //   return const SpotifyView();
          // }
          return KeyboardVisibilityBuilder(
            builder: (context, isKeyBoardOpen) {
              return Scaffold(
                body: SafeArea(
                  child: TapTo.unfocus(
                    child: Stack(
                      children: [
                        PageView(
                          controller: pageController,
                          children: [
                            // FeedPage(isPlaying),
                            Container(),
                            Container(),
                            Container(),
                            // const SearchPage(),
                            // NotificationsPage(isPlaying),
                          ],
                        ),
                        if (!isKeyBoardOpen && p.getState != PlayerState.close)
                          const Positioned(
                            right: 0,
                            left: 0,
                            bottom: 93,
                            child: PlayerWidget(),
                          ),
                        if (!isKeyBoardOpen)
                          Positioned(
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
                                      selectedItemColor:
                                          const Color(0xFFD74EFF),
                                      unselectedItemColor:
                                          const Color(0xB2FFFFFF),
                                      onTap: goToDestination,
                                      currentIndex: destination.index,
                                      items: const [
                                        BottomNavigationBarItem(
                                          label: 'Home',
                                          icon: Icon(Icons.home),
                                          activeIcon: Icon(
                                            Icons.home,
                                            color: Color(0xFFD74EFF),
                                          ),
                                        ),
                                        BottomNavigationBarItem(
                                          label: 'Search',
                                          icon: Icon(Icons.search),
                                          activeIcon: Icon(Icons.search),
                                        ),
                                        BottomNavigationBarItem(
                                          label: 'Notifications',
                                          icon: Icon(Icons.notifications),
                                          activeIcon: Icon(Icons.notifications),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
