import 'package:flutter/material.dart';

class PreferredAppBar extends StatelessWidget with PreferredSizeWidget {
  final bool automaticImplyLeading;

  PreferredAppBar(this.automaticImplyLeading, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PreferredSize(
      preferredSize: preferredSize,
      child: AppBar(
        backgroundColor: theme.primaryColor,
        automaticallyImplyLeading: automaticImplyLeading,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
