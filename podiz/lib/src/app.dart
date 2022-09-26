import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/notifications/data/push_notifications_repository.dart';

import 'features/auth/data/auth_repository.dart';
import 'features/showcase/data/showcase_repository.dart';
import 'features/showcase/presentation/package_files/showcase_widget.dart';
import 'features/showcase/presentation/showcase_controller.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'routing/app_router.dart';
import 'statistics/mix_panel_repository.dart';
import 'theme/app_theme.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    ref.read(pushNotificationsRepositoryProvider).handleNotifications();
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
