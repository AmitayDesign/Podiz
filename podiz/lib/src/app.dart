import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/splashScreen.dart';
import 'package:podiz/src/routing/app_router.dart';

import 'features/auth/data/auth_repository.dart';
import 'theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstUserValue = ref.watch(firstUserFutureProvider);
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
        builder: (context, child) => firstUserValue.when(
          error: (e, _) => SplashScreen.error(), //!
          loading: () => SplashScreen(), //!
          data: (_) {
            setScreenSize(context); //!
            return child!;
          },
        ),
      ),
    );
  }
}
