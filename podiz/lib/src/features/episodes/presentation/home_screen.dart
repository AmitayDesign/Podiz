import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/aspect/widgets/tap_to_unfocus.dart';
import 'package:podiz/home/notifications/NotificationsPage.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/domain/mutable_user_podiz.dart';
import 'package:podiz/src/features/discussion/data/presence_repository.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/presentation/feed/feed_page.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/domain/playing_episode.dart';
import 'package:podiz/src/features/player/presentation/player.dart';
import 'package:podiz/src/features/search/presentation/search_screen.dart';
import 'package:podiz/src/routing/app_router.dart';

enum HomePage { feed, search, notifications }

class HomeScreen extends ConsumerStatefulWidget {
  final HomePage? destination;
  const HomeScreen({Key? key, this.destination}) : super(key: key);

  static const bottomBarHeigh = 64.0;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

/// Use the [AutomaticKeepAliveClientMixin] to keep the state.
class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late var destination = widget.destination ?? HomePage.feed;
  late final pageController = PageController(initialPage: destination.index);

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
    // call 'super.build' when using 'AutomaticKeepAliveClientMixin'
    super.build(context);

    return Scaffold(
      body: Column(children: [
        TextButton(
          onPressed: () async {
            print('GETTING IMPAULSIVE');
            await ref
                .read(episodeRepositoryProvider)
                .fetchEpisode('36PzTdM4rvRPaJYdBW1ZNa');
            print('DONE GETTING IMPAULSIVE');
          },
          child: const Text('fetch impaulsive show'),
        ),
        TextButton(
          onPressed: () async {
            print('GETTING VIEWS');
            await ref
                .read(episodeRepositoryProvider)
                .fetchEpisode('36PzTdM4rvRPaJYdBW1ZNa');
            print('DONE GETTING VIEWS');
          },
          child: const Text('fetch views episode'),
        ),
        TextButton(
          onPressed: () async {
            print('GETTING VIEWS');
            print('DONE GETTING VIEWS');
          },
          child: const Text('search unfiltered'),
        ),
      ]),
    );

    ref.listen<AsyncValue<PlayingEpisode?>>(
      playerStateChangesProvider,
      (lastEpisodeValue, episodeValue) {
        final lastEpisodeId = lastEpisodeValue?.valueOrNull?.id;
        final wasPlaying = lastEpisodeValue?.valueOrNull?.isPlaying ?? false;
        episodeValue.whenData((episode) {
          if (episode == null) return;
          final presenceRepository = ref.read(presenceRepositoryProvider);
          // update last listened
          final user = ref
              .read(currentUserProvider)
              .updateLastListenedEpisode(episode.id);
          ref.read(authRepositoryProvider).updateUser(user);
          // update listening right now
          if (!wasPlaying && episode.isPlaying) {
            presenceRepository.configureUserPresence(user.id, episode.id);
          } else if (wasPlaying && !episode.isPlaying) {
            presenceRepository.disconnect();
          } else if (wasPlaying &&
              episode.isPlaying &&
              lastEpisodeId == episode.id) {
            presenceRepository.updateLastListened(user.id, episode.id);
          }
        });
      },
    );

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
              ],
            ),
          ),
        );
      },
    );
  }
}
