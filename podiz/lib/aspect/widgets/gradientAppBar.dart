import 'package:flutter/material.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/appBarGradient.dart';

class GradientAppBar extends StatelessWidget with PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  const GradientAppBar({Key? key, this.title, this.actions}) : super(key: key);

  static const height = 64.0;
  static const backgroundHeight = height * 1.25;

  @override
  Size get preferredSize => const Size.fromHeight(backgroundHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      toolbarHeight: height,
      title: title,
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: extendedAppBarGradient(context.colorScheme.background),
        ),
        height: preferredSize.height + MediaQuery.of(context).padding.top,
      ),
    );
  }
}
