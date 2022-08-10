import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/app_router.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/themeConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences preferences;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Locales.init(['en']);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer();

  //TODO call no internet dialog
  await Firebase.initializeApp()
      .catchError((onError) => print("call no internet dialog"));

  // container.read(authManagerProvider).firstUserLoad.then(
  //       (_) => FlutterNativeSplash.remove(),
  //     );

  // PushNotificationService.init(container.read);
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
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
    final goRouter = ref.watch(goRouterProvider);
    return LocaleBuilder(
      builder: (locale) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: Locales.delegates,
        supportedLocales: Locales.supportedLocales,
        locale: locale,
        routerDelegate: goRouter.routerDelegate,
        routeInformationParser: goRouter.routeInformationParser,
        routeInformationProvider: goRouter.routeInformationProvider,
        restorationScopeId: 'app',
        theme: ThemeConfig.light,
        themeMode: ref.watch(themeModeProvider),
        builder: (context, child) {
          setScreenSize(context);
          return child!;
        },
      ),
    );
  }
}
