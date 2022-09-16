import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/splash/presentation/splash_screen.dart';

import 'connect_controller.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  @override
  void initState() {
    super.initState();
    signIn();
  }

  Future<void> signIn() =>
      ref.read(connectionControllerProvider.notifier).signIn();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(connectionControllerProvider);
    return !state.isRefreshing && state.hasError
        ? SplashScreen.error(onRetry: signIn)
        : const SplashScreen();
  }
}
