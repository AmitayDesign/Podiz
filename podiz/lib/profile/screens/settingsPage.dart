import 'package:flutter/material.dart';
import 'package:podiz/profile/components.dart/backAppBar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);
  static const route = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(),
      body: const Text("Settings"),
    );
  }
}
