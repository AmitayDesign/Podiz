import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/onboarding/components/podizAppBar.dart';
import 'package:podiz/onboarding/components/spotifyContainer.dart';
import 'package:podiz/splashScreen.dart';

import 'spotify_controller.dart';

class ConnectBudzPage extends ConsumerWidget {
  const ConnectBudzPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(spotifyControllerProvider, (_, state) {
      if (!state.isRefreshing && state.hasError) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(state.error.toString()),
          ),
        );
      }
    });
    final state = ref.watch(spotifyControllerProvider);
    if (state.isLoading) return const SplashScreen();
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/backgroundImage.png'),
                  fit: BoxFit.cover),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 96),
                  const Spacer(),
                  const SpotifyContainer(),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(spotifyControllerProvider.notifier).signIn(),
                    child: Text(
                      Locales.string(context, "intro4"),
                      style: theme.textTheme.button,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: PodizAppBar(),
          ),
        ],
      ),
    );
  }
}
