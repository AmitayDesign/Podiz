import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/objects/AuthorizationModel.dart';
import 'package:podiz/onboarding/SpotifyManager.dart';
import 'package:podiz/onboarding/onbordingPage.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/splashScreen.dart';

class SpotifyView extends ConsumerStatefulWidget {
  static const route = '/spotifyView';
  SpotifyView({Key? key}) : super(key: key);

  @override
  ConsumerState<SpotifyView> createState() => _SpotifyViewState();
}

class _SpotifyViewState extends ConsumerState<SpotifyView> {
  @override
  Widget build(BuildContext context) {
    SpotifyManager spotifyManager = ref.read(spotifyManagerProvider);
    spotifyManager.fetchAuthorizationCode();

    _bienvenido() {
      spotifyManager.disposeToken();
      AuthManager authManager = ref.read(authManagerProvider);
      // PlayerManager playerManager = ref.read(playerManagerProvider);
      // playerManager.playerBloc.error = false;
      Timer(
        Duration(milliseconds: 0),
        () => Navigator.pushNamedAndRemoveUntil(
          context,
          HomePage.route,
          (route) => false,
          arguments: authManager.userBloc!,
        ),
      );
      return SplashScreen();
    }

    return Scaffold(
      body: StreamBuilder(
        stream: spotifyManager.authorizationCode,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == "access_denied") {
              Navigator.pop(context);
            } else {
              spotifyManager.fetchAuthorizationToken(snapshot.data!);
              return StreamBuilder(
                stream: spotifyManager.authorizationToken,
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return FutureBuilder(
                      initialData: "loading",
                      future: spotifyManager.setUpAuthStream(snapshot),
                      builder: ((context, snapshot) {
                        if (snapshot.data == "loading" ||
                            snapshot.connectionState != ConnectionState.done) {
                          return SplashScreen();
                        }
                        return _bienvenido();
                      }),
                    );
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return SplashScreen();
                },
              );
            }
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return SplashScreen();
        },
      ),
    );
  }
}
