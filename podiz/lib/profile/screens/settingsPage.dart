import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/profile/components.dart/backAppBar.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);
  static const route = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: BackAppBar(),
      body: Center(
        child: TextButton(
          onPressed: () => ref.read(authManagerProvider).signOut(),
          child: const Text('Sign Out'),
        ),
      ),
    );
  }
}
