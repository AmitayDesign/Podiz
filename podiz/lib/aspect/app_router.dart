import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/home/search/screens/showPage.dart';
import 'package:podiz/onboarding/connectBudz.dart';
import 'package:podiz/onboarding/onbordingPage.dart';
import 'package:podiz/player/screens/discussionPage.dart';
import 'package:podiz/profile/profilePage.dart';
import 'package:podiz/profile/screens/settingsPage.dart';

enum AppRoute {
  home,
  onBoarding,
  connectBudz,
  discussion,
  profile,
  settings,
  show,
}

//TODO when logged in (no premium?) -> stuck on black screen

final goRouterProvider = Provider<GoRouter>((ref) {
  final authManager = ref.watch(authManagerProvider);
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (state) {
      final isLoggedIn = authManager.currentUser != null;
      if (isLoggedIn) {
        if (state.location.contains('/on-boarding')) return '/';
      } else {
        if (!state.location.contains('/on-boarding')) return '/on-boarding';
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authManager.user),
    routes: [
      GoRoute(
        path: '/on-boarding',
        name: AppRoute.onBoarding.name,
        builder: (_, state) => const OnBoardingPage(),
        routes: [
          GoRoute(
            path: 'connect-budz',
            name: AppRoute.connectBudz.name,
            builder: (_, state) => const ConnectBudzPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (_, state) {
          final destinationName = state.queryParams['destination'];
          final destination = HomeDestination.values.firstWhereOrNull(
            (d) => d.name == destinationName,
          );
          return HomePage(destination: destination);
        },
        routes: [
          GoRoute(
            path: 'settings',
            name: AppRoute.settings.name,
            builder: (_, state) => const SettingsPage(),
          ),
          GoRoute(
            path: 'profile/:userId',
            name: AppRoute.profile.name,
            builder: (_, state) {
              final userId = state.params['userId']!;
              return ProfilePage(userId: userId);
            },
          ),
          GoRoute(
            path: 'show/:showId',
            name: AppRoute.show.name,
            builder: (_, state) {
              final showId = state.params['showId']!;
              return ShowPage(showId);
            },
            routes: [
              GoRoute(
                path: 'discussion',
                name: AppRoute.discussion.name,
                builder: (_, state) => const DiscussionPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
