import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/home/search/screens/showPage.dart';
import 'package:podiz/onboarding/onbordingPage.dart';
import 'package:podiz/player/screens/discussionPage.dart';
import 'package:podiz/profile/profilePage.dart';
import 'package:podiz/profile/screens/settingsPage.dart';

enum AppRoute {
  home,
  onboarding,
  discussion,
  profile,
  settings,
  show,
}

//TODO test login in no premium account

final goRouterProvider = Provider<GoRouter>((ref) {
  final authManager = ref.watch(authManagerProvider);
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (state) {
      final isLoggedIn = authManager.currentUser != null;
      if (isLoggedIn) {
        if (state.location.contains('/onboarding')) return '/';
      } else {
        if (!state.location.contains('/onboarding')) return '/onboarding';
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authManager.user),
    routes: [
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        builder: (_, state) => const OnboardingPage(),
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
