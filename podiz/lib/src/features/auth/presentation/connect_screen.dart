import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/splash/presentation/splash_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'connect_controller.dart';

class ConnectScreen extends ConsumerWidget {
  const ConnectScreen({Key? key}) : super(key: key);

  Future<NavigationDecision> handleNavigation(WidgetRef ref, String url) async {
    final controller = ref.read(connectionControllerProvider.notifier);
    if (!controller.isValidUrl(url)) return NavigationDecision.navigate;
    await controller.signIn(url);
    return NavigationDecision.prevent;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(connectionControllerProvider.notifier);
    final state = ref.watch(connectionControllerProvider);
    return Stack(
      children: [
        WebView(
          initialUrl: controller.connectionUrl,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (req) => handleNavigation(ref, req.url),
          onPageStarted: (_) => controller.init(),
        ),
        if (state.isLoading) const SplashScreen(),
        if (!state.isRefreshing && state.hasError)
          SplashScreen.error(onRetry: controller.retrySignIn),
      ],
    );
  }
}
