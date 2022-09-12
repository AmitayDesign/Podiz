import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:podiz/src/app.dart';
import 'package:podiz/src/features/notifications/data/push_notifications_repository.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/utils/instances.dart';

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      final providerContainer = ProviderContainer();

      Mixpanel mixpanel = await Mixpanel.init(
          "d293ecfa9c2739d850381d9e245b7437",
          optOutTrackingDefault: false);
      mixpanel.track("openApp");
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
      await providerContainer.read(preferencesFutureProvider.future);
      await providerContainer.read(pushNotificationsRepositoryProvider).init();

      //* Entry point of the app
      runApp(UncontrolledProviderScope(
        container: providerContainer,
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
