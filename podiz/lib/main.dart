import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/routerConfig.dart';
import 'package:podiz/aspect/theme/themeConfig.dart';
import 'package:podiz/aspect/widgets/routeAwareState.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/onboarding/onbordingPage.dart';
import 'package:podiz/profile/followerProfilePage.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences preferences;

void main() async {
   final container = ProviderContainer();
  // WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.removeAfter((context) async {
    await container.read(authManagerProvider).firstUserLoad;
  });

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //TODO call no internet dialog
  await Firebase.initializeApp()
      .catchError((onError) => print("call no internet dialog"));

  preferences = await SharedPreferences.getInstance();
  await Locales.init(['en']);
  runApp(UncontrolledProviderScope(container: container, child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    updateBrightness();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    updateBrightness();
  }

  void updateBrightness() => ref.read(brightnessProvider.notifier).update();

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userStreamProvider);
    return LocaleBuilder(
      builder: (locale) => MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorObservers: [RouteAwareState.observer],
          localizationsDelegates: Locales.delegates,
          supportedLocales: Locales.supportedLocales,
          theme: ThemeConfig.light,
          themeMode: ref.watch(themeModeProvider),
          routes: RouterConfig.routes,
          builder: (context, child) {
            setScreenSize(context);
            return child!;
          },
          locale: locale,
          home: user.maybeWhen(
            data: (user) {
              print(user);
              // if (user == null) return OnBoardingPage();
              // return OnBoardingPage();
              return HomePage();
              // final podcasts = ref.watch(podcastsStreamProvider); //create
              // return podcasts.maybeWhen(
              //     data: (_) => HomePage(), //create
              //     loading: () => SplashScreen(),
              //     orElse: () => SplashScreen.error());
            },
            loading: () => SplashScreen(),
            orElse: () => SplashScreen.error(),
          )),
    );
  }
}