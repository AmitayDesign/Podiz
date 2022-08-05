import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/routerConfig.dart';
import 'package:podiz/aspect/theme/themeConfig.dart';
import 'package:podiz/aspect/widgets/routeAwareState.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/home/notifications/PushNotificationService.dart';
import 'package:podiz/onboarding/onbordingPage.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences preferences;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  final container = ProviderContainer();
  // WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.removeAfter((context) async {
    await container.read(authManagerProvider).firstUserLoad;
  });

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //TODO call no internet dialog
  var firebaseApp = await Firebase.initializeApp()
      .catchError((onError) => print("call no internet dialog"));

  preferences = await SharedPreferences.getInstance();
  await Locales.init(['en']);
  
  // PushNotificationService.init(container.read);
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
    // PushNotificationService.instance.onNotification();
    updateBrightness();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    updateBrightness();
  }

  void updateBrightness() => ref.read(brightnessProvider.notifier).update();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userStreamProvider);
    print("building main");
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
              print("USER " + user.toString());
              if (user == null) return OnBoardingPage();
              return HomePage(user);
            },
            loading: () => SplashScreen(),
            orElse: () => SplashScreen.error(),
          )),
    );
  }
}
