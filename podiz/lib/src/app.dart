import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/presentation/sign_in_screen.dart';
import 'package:podiz/src/routing/app_router.dart';

import 'features/auth/data/auth_repository.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final theme = ref.watch(themeProvider);
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
        builder: (context, child) => Consumer(builder: (context, ref, _) {
          final firstUserValue = ref.watch(firstUserFutureProvider);
          return firstUserValue.when(
            error: (e, _) => const SplashScreen.error(),
            loading: () => const SplashScreen(),
            data: (user) {
              print('user: $user');
              if (user == null) return child!;
              final firstConnectionValue =
                  ref.watch(firstConnectionFutureProvider);
              return firstConnectionValue.when(
                error: (e, _) => const SplashScreen.error(),
                loading: () => const SignInScreen(),
                data: (connection) {
                  print('connection: $connection');
                  return child!;
                },
              );
            },
          );
        }),
      ),
    );
  }
}
