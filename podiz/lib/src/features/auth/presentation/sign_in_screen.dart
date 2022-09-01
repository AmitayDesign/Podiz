import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/features/auth/data/spotify_api.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'onboarding/onboarding_bar.dart';
import 'onboarding/onboarding_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  Future<NavigationDecision> handleNavigation(NavigationRequest req) async {
    final response = req.url;
    final error = Uri.parse(response).queryParameters['error'];
    if (error == null) {
      final code = Uri.parse(response).queryParameters['code']!;
      await ref.read(onboardingControllerProvider.notifier).signIn(code);
    }

    var popped = false;
    if (mounted) popped = await Navigator.maybePop(context);
    if (mounted && !popped) context.goNamed(AppRoute.home.name);
    return NavigationDecision.prevent;
  }

  @override
  Widget build(BuildContext context) {
    final spotifyApi = ref.watch(spotifyApiProvider);
    return Scaffold(
      appBar: const OnboardingBar(),
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.background,
          image: const DecorationImage(
            image: AssetImage('assets/images/backgroundImage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: WebView(
          // backgroundColor: Colors.transparent,
          initialUrl: spotifyApi.authenticationUrl,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: handleNavigation,
        ),
      ),
    );
    // on success: signIn(code)
  }
}
