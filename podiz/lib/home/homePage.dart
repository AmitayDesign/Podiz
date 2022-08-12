import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/widgets/tap_to_unfocus.dart';
import 'package:podiz/home/feed/feedPage.dart';
import 'package:podiz/home/notifications/NotificationsPage.dart';
import 'package:podiz/home/search/searchPage.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/playerWidget.dart';
import 'package:podiz/providers.dart';

enum HomeDestination { feed, search, notifications }

class HomePage extends ConsumerStatefulWidget {
  final HomeDestination? destination;
  const HomePage({Key? key, this.destination}) : super(key: key);

  static const bottomBarHeigh = 88.0;

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

    ref.listen<AsyncValue<PlayerState>>(stateProvider, (_, stateValue) {
      final state = stateValue.valueOrNull;
      // Future.microtask(() {});
      setState(() => isPlaying = state != null && state != PlayerState.close);
    });

    return KeyboardVisibilityBuilder(
      builder: (context, isKeyBoardOpen) {
        return TapToUnfocus(
          child: Scaffold(
            extendBody: true,
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView(
                  controller: pageController,
                  children: [
                    FeedPage(isPlaying),
                    const SearchPage(),
                    NotificationsPage(isPlaying),
                  ],
                ),
                //TODO playerwidget
                if (!isKeyBoardOpen && isPlaying)
                  const Padding(
                    padding: EdgeInsets.only(bottom: HomePage.bottomBarHeigh),
                    child: PlayerWidget(),
                  ),
              ],
            ),
            bottomNavigationBar: SizedBox(
              height: HomePage.bottomBarHeigh,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: BottomNavigationBar(
                    onTap: goToDestination,
                    currentIndex: destination.index,
                    items: const [
                      BottomNavigationBarItem(
                        label: 'Home',
                        icon: Icon(Icons.home),
                      ),
                      BottomNavigationBarItem(
                        label: 'Search',
                        icon: Icon(Icons.search),
                      ),
                      BottomNavigationBarItem(
                        label: 'Notifications',
                        icon: Icon(Icons.notifications),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
