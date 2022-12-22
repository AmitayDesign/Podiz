import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/features/notifications/data/push_notifications_repository.dart';
import 'package:podiz/src/features/player/data/player_repository.dart';
import 'package:uni_links/uni_links.dart';

import 'features/auth/data/auth_repository.dart';
import 'features/showcase/data/showcase_repository.dart';
import 'features/showcase/presentation/package_files/showcase_widget.dart';
import 'features/showcase/presentation/showcase_controller.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'routing/app_router.dart';
import 'statistics/mix_panel_repository.dart';
import 'theme/app_theme.dart';

class MyApp extends ConsumerStatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(pushNotificationsRepositoryProvider).handleNotifications();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.refresh(playerStateChangesProvider);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(goRouterProvider);
    final theme = ref.watch(themeProvider);
    //TODO see if this in the right place
    ref.watch(mixPanelRepository).init();
    return LocaleBuilder(
      builder: (locale) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Podiz',
        localizationsDelegates: Locales.delegates,
        supportedLocales: Locales.supportedLocales,
        locale: locale,
        routerDelegate: goRouter.routerDelegate,
        routeInformationParser: goRouter.routeInformationParser,
        routeInformationProvider: goRouter.routeInformationProvider,
        restorationScopeId: 'app',
        darkTheme: theme,
        themeMode: ThemeMode.dark,
        builder: (context, child) {
          // return child!;
          return ShowCaseWidget(
            disableAnimation: true,
            disableBarrierInteraction: true,
            onStart: (_, __) {
              return ref.read(showcaseRunningProvider.notifier).state = true;
            },
            onFinish: () {
              ref.read(showcaseRunningProvider.notifier).state = false;
              final user = ref.read(currentUserProvider);
              ref.read(showcaseRepositoryProvider).disable(user.id);
            },
            child: Consumer(builder: (context, ref, _) {
              final firstConnectionValue = ref.watch(firstUserFutureProvider);
              return firstConnectionValue.when(
                error: (e, _) => SplashScreen.error(
                  onRetry: () => ref.refresh(firstUserFutureProvider),
                ),
                loading: () => const SplashScreen(),
                data: (_) => child!,
              );
            }),
          );
        },
      ),
    );
  }
}
