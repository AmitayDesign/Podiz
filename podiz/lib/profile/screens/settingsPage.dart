import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/profile/components.dart/back_bar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);
  static const route = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: BackBar(),
      body: Center(
        child: TextButton(
          onPressed: () => ref.read(authRepositoryProvider).signOut(),
          child: const Text('Sign Out'),
        ),
      ),
    );
  }
}
