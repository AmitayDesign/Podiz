import 'package:flutter/material.dart';

class TapToUnfocus extends StatelessWidget {
  final Widget child;
  const TapToUnfocus({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
