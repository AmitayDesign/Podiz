import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/home/homePage.dart';
import 'package:podiz/objects/AuthorizationModel.dart';
import 'package:podiz/onboarding/SpotifyManager.dart';

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
      Timer(
          Duration(microseconds: 0),
          () => Navigator.pushNamedAndRemoveUntil(
              context, HomePage.route, (route) => false));
      return Center(child: CircularProgressIndicator());
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
                    spotifyManager.setUpAuthStream(snapshot);
                    return _bienvenido();
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            }
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
