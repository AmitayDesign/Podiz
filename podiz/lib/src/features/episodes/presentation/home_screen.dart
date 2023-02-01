import 'dart:async';
import 'dart:ui';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/common_widgets/tap_to_unfocus.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/features/auth/data/user_repository.dart';
import 'package:podiz/src/features/auth/domain/mutable_user_podiz.dart';
import 'package:podiz/src/features/discussion/data/discussion_repository.dart';
import 'package:podiz/src/features/discussion/data/presence_repository.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/episodes/presentation/feed/feed_page.dart';
import 'package:podiz/src/features/notifications/data/push_notifications_repository.dart';
import 'package:podiz/src/features/notifications/domain/notification_podiz.dart';
import 'package:podiz/src/features/notifications/presentation/notifications_page.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:podiz/src/features/player/domain/playing_episode.dart';
import 'package:podiz/src/features/player/presentation/player.dart';
import 'package:podiz/src/features/search/presentation/search_page.dart';
import 'package:podiz/src/routing/app_router.dart';

enum HomePage { feed, search, notifications }

class HomeScreen extends ConsumerStatefulWidget {
  final HomePage? destination;
  const HomeScreen({Key? key, this.destination}) : super(key: key);

  static const bottomBarHeigh = 89.0;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final pageScrollControllers = List.generate(3, (_) => ScrollController());
  late var destination = widget.destination ?? HomePage.feed;
  late final pageController = PageController(initialPage: destination.index);
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    initUniLinks();
    pageController.addListener(() {
      final page = pageController.page;
      if (page != null &&
          page == page.toInt() &&
          page.toInt() != destination.index) goToDestination(page.toInt());
    });

    connect();
  }

  Future<void> connect() async {
    // connect to sdk
    const retries = 3;
    bool success = false;
    for (var i = 0; i < retries && !success; i++) {
      success = await ref.read(spotifyApiProvider).connectToSdk();
    }
    // open playing episode
    await openPlayingEpisode();

    // request notification permission
    final user = ref.read(currentUserProvider);
    await ref
        .read(pushNotificationsRepositoryProvider)
        .requestPermission(user.id);
  }

  Future<void> openPlayingEpisode() async {
    ref.listenOnce<AsyncValue<PlayingEpisode?>>(
      firstPlayerFutureProvider,
      (_, firstEpisodeValue) => firstEpisodeValue.whenData((firstEpisode) {
        if (firstEpisode != null && firstEpisode.isPlaying) {
          context.goNamed(
            AppRoute.discussion.name,
            params: {'episodeId': firstEpisode.id},
          );
        }
      }),
    );
  }

  @override
  void dispose() {
    for (var controller in pageScrollControllers) {
      controller.dispose();
    }
    pageController.dispose();
    _sub?.cancel();
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
    context.goNamed(
      AppRoute.home.name,
      queryParams: {'destination': HomePage.values[i].name},
    );
  }

  void scrollToTheTop(int i) {
    pageScrollControllers[i].animateTo(
      0,
      duration: kTabScrollDuration,
      curve: Curves.ease,
    );
  }

  void initUniLinks() async {
    final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) handleMyLink(initialLink.link);
    FirebaseDynamicLinks.instance.onLink.listen(
        (PendingDynamicLinkData? dynamicLink) async {
      final Uri deeplink = dynamicLink!.link;
      handleMyLink(deeplink);
    }, onError: (_) {
      debugPrint("ERROR WITH DEEPLINKING");
    });
  }

  void handleMyLink(Uri uri) {
    context.goNamed(
      AppRoute.discussion.name,
      params: {"episodeId": uri.path.split("/")[2].split("?")[0]},
      queryParams: {"t": uri.queryParameters["t"]},
    );
  }

  @override
  Widget build(BuildContext context) {
    // open discussion if a notification was selected
    ref.listen<AsyncValue<NotificationPodiz>>(
      selectedNotificationStreamProvider,
      (_, notificationValue) =>
          notificationValue.whenData((notification) async {
        switch (notification.channel) {
          case Channel.replies:
            final replyId = notification.id;
            final discussionRepository = ref.read(discussionRepositoryProvider);
            final reply = await discussionRepository.fetchComment(replyId);
            final comment =
                await discussionRepository.fetchComment(reply.parentIds.first);
            if (!mounted) return;
            context.pushNamed(
              AppRoute.discussion.name,
              params: {'episodeId': comment.episodeId},
              queryParams: {'t': comment.timestamp.inSeconds.toString()},
            );
            break;
          case Channel.follows:
            final userId = notification.id;
            context.pushNamed(
              AppRoute.profile.name,
              params: {'userId': userId},
            );
            break;
        }
      }),
    );
    // update last listened on player changes
    ref.listen<AsyncValue<PlayingEpisode?>>(
      playerStateChangesProvider,
      (lastEpisodeValue, episodeValue) {
        final lastEpisodeId = lastEpisodeValue?.valueOrNull?.id;
        final wasPlaying = lastEpisodeValue?.valueOrNull?.isPlaying ?? false;
        episodeValue.whenData((episode) {
          final presenceRepository = ref.read(presenceRepositoryProvider);
          // episode is null, disconnect
          if (episode == null) return presenceRepository.disconnect();
          // else, update listening episode
          // 1. update user last listened
          final user =
              ref.read(currentUserProvider).updateLastListened(episode.id);
          ref.read(authRepositoryProvider).updateUser(user);
          // 2. update listening episode
          // pause > play
          if (!wasPlaying && episode.isPlaying) {
            presenceRepository.configureUserPresence(user.id, episode.id);
            // play > pause
          } else if (wasPlaying && !episode.isPlaying) {
            presenceRepository.disconnect();
            // play > play, diff eposide
          } else if (wasPlaying &&
              episode.isPlaying &&
              lastEpisodeId != episode.id) {
            presenceRepository.updateLastListened(user.id, episode.id);
          }
        });
      },
    );

    return WillPopScope(
      onWillPop: () async {
        if (destination == HomePage.feed) return true;
        goToDestination(0);
        return false;
      },
      child: KeyboardVisibilityBuilder(
        builder: (context, isKeyBoardOpen) {
          return TapToUnfocus(
            child: Scaffold(
              extendBody: true,
              //floatingActionButton: notificationDebugFAB(),
              //floatingActionButton: localDebugFAB(),
              body: PageView(
                controller: pageController,
                children: [
                  FeedPage(scrollController: pageScrollControllers[0]),
                  SearchPage(scrollController: pageScrollControllers[1]),
                  NotificationsPage(scrollController: pageScrollControllers[2]),
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
                          onTap: (i) => i != destination.index
                              ? goToDestination(i)
                              : scrollToTheTop(i),
                          currentIndex: destination.index,
                          items: const [
                            BottomNavigationBarItem(
                              label: 'Home',
                              icon: Icon(Icons.home_rounded),
                            ),
                            BottomNavigationBarItem(
                              label: 'Search',
                              icon: Icon(Icons.search_rounded),
                            ),
                            BottomNavigationBarItem(
                              label: 'Notifications',
                              icon: Icon(Icons.notifications_rounded),
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
      ),
    );
  }

  Widget localDebugFAB() => FloatingActionButton(
      child: const Icon(Icons.notifications),
      onPressed: () =>
          ref.read(pushNotificationsRepositoryProvider).debugDisplay());

  Widget notificationDebugFAB() {
    final userId = ref.read(currentUserProvider).id;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          child: const Icon(Icons.person_add),
          onPressed: () async {
            final repo = ref.read(userRepositoryProvider);
            await repo.unfollow('hmrs28xr9apw0mlac2dfjwm2v', userId);
            await repo.follow('hmrs28xr9apw0mlac2dfjwm2v', userId);
          },
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          child: const Icon(Icons.comment),
          onPressed: () async {
            final repo = ref.read(discussionRepositoryProvider);
            final comment = Comment(
              episodeId: '4HuFbACVWnSi7FJWJ5LrKA',
              text: 'That\'s awesome',
              timestamp: const Duration(milliseconds: 571478),
              userId: userId,
            );
            final commentId = await repo.addComment(comment);
            final reply = Comment(
              episodeId: '4HuFbACVWnSi7FJWJ5LrKA',
              parentIds: [commentId],
              parentUserId: userId,
              text: 'I agree, what a tip. This will help me so much',
              timestamp: const Duration(milliseconds: 571478),
              userId: 'hmrs28xr9apw0mlac2dfjwm2v',
            );
            await repo.addComment(reply);
          },
        ),
      ],
    );
  }
}
