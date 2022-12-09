import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
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
import 'package:podiz/src/routing/refresh_stream_list.dart';

enum AppRoute {
  onboarding,
  home,
  profile,
  settings,
  privacy,
  podcast,
  discussion,
}

String initialRedirect = '';
bool isFirstTime = true;

final goRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (state) {
      final isLoggedIn = authRepository.currentUser != null;
      final hasEmail = authRepository.currentUser?.email != null;
      final isConnected = authRepository.isConnected;
      final isOnboardingLocation = state.location.contains('/onboarding');
      final isEmailLocation =
          isOnboardingLocation && state.queryParams['page'] == 'email';

      if (isOnboardingLocation && !isEmailLocation) {
        if (isLoggedIn && isConnected) {
          if (!hasEmail) return '/onboarding?page=email';
          // clear redirect and go to home or somewhere on app
          final redirect = initialRedirect.isEmpty ? '/' : initialRedirect;
          initialRedirect = '';
          return redirect;
        } else {
          return null;
        }
      } else if (!isEmailLocation) /* somewhere in the app */ {
        if (isLoggedIn && isConnected) {
          if (!hasEmail) return '/onboarding?page=email';
          return null;
        } else {
          // save redirect while connecting
          if (isLoggedIn) initialRedirect = state.location;
          if (Platform.isAndroid || isFirstTime) {
            isFirstTime = false;
            return '/onboarding';
          }
        }
      } else /* email location */ {
        if (hasEmail) return '/';
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStreamList([
      authRepository.authStateChanges(),
      authRepository.connectionChanges(),
    ]),
    routes: [
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        builder: (_, state) {
          final pageName = state.queryParams['page'];
          final page = OnboardingPage.values.firstWhereOrNull(
            (p) => p.name == pageName,
          );
          return OnboardingScreen(page: page);
        },
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
              Duration? time;
              final secondsString = state.queryParams['t'];
              if (secondsString != null) {
                final seconds = int.tryParse(secondsString);
                if (seconds != null) time = Duration(seconds: seconds);
              }
              return DiscussionScreen(
                episodeId,
                time: time,
                key: UniqueKey(),
              );
            },
          ),
        ],
      ),
    ],
  );
});
