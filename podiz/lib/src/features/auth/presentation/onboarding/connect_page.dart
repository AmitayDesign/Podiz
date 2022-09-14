import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/presentation/connect_controller.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ConnectPage extends ConsumerWidget {
  const ConnectPage({Key? key}) : super(key: key);

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
          initialUrl: Uri.parse(controller.connectionUrl).toString(),
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (req) => handleNavigation(ref, req.url),
          onPageStarted: (_) => controller.init(),
        ),
        if (state.isLoading)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: CircularProgressIndicator(color: Palette.green),
              ),
              const SizedBox(height: 24),
              Text(
                'Waiting for Spotify',
                style: context.textTheme.bodyLarge!
                    .copyWith(color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        if (!state.isRefreshing && state.hasError) ...[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LocaleText(
                'error1',
                style: context.textTheme.bodyLarge!
                    .copyWith(color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(primary: Palette.green),
                  onPressed: controller.retrySignIn,
                  label: const Text(
                    'Retry',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
