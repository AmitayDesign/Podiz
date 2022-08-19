import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/presentation/onboarding/onboarding_screen.dart';
import 'package:podiz/src/features/auth/presentation/profile/profile_screen.dart';
import 'package:podiz/src/features/discussion/presentation/discussion_screen.dart';
import 'package:podiz/src/features/episodes/presentation/home_screen.dart';
import 'package:podiz/src/features/episodes/presentation/podcast/podcast_screen.dart';
import 'package:podiz/src/features/settings/presentation/privacy_screen.dart';
import 'package:podiz/src/features/settings/presentation/settings_screen.dart';

enum AppRoute {
  home,
  onboarding,
  profile,
  settings,
  privacy,
  podcast,
  discussion,
}

//TODO test login in no premium account

final goRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (state) {
      final isLoggedIn = authRepository.currentUser != null;
      if (isLoggedIn) {
        if (state.location.contains('/onboarding')) return '/';
      } else {
        if (!state.location.contains('/onboarding')) return '/onboarding';
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    routes: [
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        builder: (_, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (_, state) {
          final destinationName = state.queryParams['destination'];
          final destination = HomePage.values.firstWhereOrNull(
            (d) => d.name == destinationName,
          );
          return HomeScreen(destination: destination);
        },
        routes: [
          GoRoute(
            path: 'settings',
            name: AppRoute.settings.name,
            builder: (_, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'privacy',
                name: AppRoute.privacy.name,
                builder: (_, state) => const PrivacyScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'profile/:userId',
            name: AppRoute.profile.name,
            builder: (_, state) {
              final userId = state.params['userId']!;
              return ProfileScreen(userId);
            },
          ),
          GoRoute(
            path: 'podcast/:podcastId',
            name: AppRoute.podcast.name,
            builder: (_, state) {
              final podcastId = state.params['podcastId']!;
              return PodcastScreen(podcastId);
            },
          ),
          GoRoute(
            path: 'discussion/:episodeId',
            name: AppRoute.discussion.name,
            builder: (_, state) {
              final episodeId = state.params['episodeId']!;
              return DiscussionScreen(episodeId);
            },
          ),
        ],
      ),
    ],
  );
});
