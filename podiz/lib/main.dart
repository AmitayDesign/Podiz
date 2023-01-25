import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/app.dart';
import 'package:podiz/src/features/discussion/presentation/sound_controller.dart';
import 'package:podiz/src/features/notifications/data/push_notifications_repository.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/statistics/mix_panel_repository.dart';
import 'package:podiz/src/utils/instances.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Locales.init(['en']);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      LicenseRegistry.addLicense(() async* {
        final license = await rootBundle.loadString(
          'assets/google_fonts/montserratOFL.txt',
        );
        yield LicenseEntryWithLineBreaks(['google_fonts'], license);
      });

      await Firebase.initializeApp();

      // if (Platform.isIOS) {
      //   final PendingDynamicLinkData? initialLink =
      //       await FirebaseDynamicLinks.instance.getInitialLink();
      //   if (initialLink != null) {
      //     Uri deepLink = initialLink.link;
      //     initialRedirect =
      //         deepLink.path + "?t=" + deepLink.queryParameters['t']!;
      //   }
      // }

      //* Providers initialization
      final preferences = await StreamingSharedPreferences.instance;
      final container = ProviderContainer(overrides: [
        preferencesProvider.overrideWithValue(preferences),
      ]);
      await container.read(beepControllerProvider).init();
      await container.read(pushNotificationsRepositoryProvider).init();
      await container.read(mixPanelRepository).init();

      //* Entry point of the app
      runApp(UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ));

      //! This code will present some error UI if any uncaught exception happens
      FlutterError.onError = (details) => FlutterError.presentError(details);
      ErrorWidget.builder = (details) => Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.red,
              title: Text('An error occurred'.hardcoded),
            ),
            body: Center(child: Text(details.toString())),
          );
    },
    (error, _) => debugPrint(error.toString()),
  );
}
