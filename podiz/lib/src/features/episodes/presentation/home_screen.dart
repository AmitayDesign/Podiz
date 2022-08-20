import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/common_widgets/tap_to_unfocus.dart';
import 'package:podiz/src/features/episodes/presentation/feed/feed_page.dart';
import 'package:podiz/src/features/notifications/presentation/notifications_page.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/domain/playing_episode.dart';
import 'package:podiz/src/features/player/presentation/player.dart';
import 'package:podiz/src/features/search/presentation/search_screen.dart';
import 'package:podiz/src/routing/app_router.dart';

enum HomePage { feed, search, notifications }

class HomeScreen extends ConsumerStatefulWidget {
  final HomePage? destination;
  const HomeScreen({Key? key, this.destination}) : super(key: key);

  static const bottomBarHeigh = 72.0;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late var destination = widget.destination ?? HomePage.feed;
  late final pageController = PageController(initialPage: destination.index);

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
  void didUpdateWidget(covariant HomeScreen oldWidget) {
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
        queryParams: {'destination': HomePage.values[i].name},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<PlayingEpisode?>>(
      firstEpisodeFutureProvider,
      (_, firstEpisodeValue) {
        firstEpisodeValue.whenData((firstEpisode) {
          if (firstEpisode != null && firstEpisode.isPlaying) {
            context.goNamed(
              AppRoute.discussion.name,
              params: {'episodeId': firstEpisode.id},
            );
          }
        });
      },
    );
    // ref.listen<AsyncValue<PlayingEpisode?>>(
    //   playerStateChangesProvider,
    //   (lastEpisodeValue, episodeValue) {
    //     final lastEpisodeId = lastEpisodeValue?.valueOrNull?.id;
    //     final wasPlaying = lastEpisodeValue?.valueOrNull?.isPlaying ?? false;
    //     episodeValue.whenData((episode) {
    //       if (episode == null) return;
    //       final presenceRepository = ref.read(presenceRepositoryProvider);
    //       // update last listened
    //       final user = ref
    //           .read(currentUserProvider)
    //           .updateLastListenedEpisode(episode.id);
    //       ref.read(authRepositoryProvider).updateUser(user);
    //       // update listening right now
    //       if (!wasPlaying && episode.isPlaying) {
    //         presenceRepository.configureUserPresence(user.id, episode.id);
    //       } else if (wasPlaying && !episode.isPlaying) {
    //         presenceRepository.disconnect();
    //       } else if (wasPlaying &&
    //           episode.isPlaying &&
    //           lastEpisodeId == episode.id) {
    //         presenceRepository.updateLastListened(user.id, episode.id);
    //       }
    //     });
    //   },
    // );

    return KeyboardVisibilityBuilder(
      builder: (context, isKeyBoardOpen) {
        return TapToUnfocus(
          child: Scaffold(
            extendBody: true,
            body: PageView(
              controller: pageController,
              children: const [
                FeedPage(),
                SearchPage(),
                NotificationsPage(),
              ],
            ),
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Player(),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: SizedBox(
                      height: HomeScreen.bottomBarHeigh,
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
              ],
            ),
          ),
        );
      },
    );
  }
}
