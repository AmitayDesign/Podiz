import 'package:flutter/material.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/appBarGradient.dart';

class GradientBar extends StatelessWidget with PreferredSizeWidget {
  final bool automaticallyImplyLeading;
  final Widget? title;
  final List<Widget>? actions;
  final bool? centerTitle;

  const GradientBar({
    Key? key,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.centerTitle,
  }) : super(key: key);

  static const height = 64.0;
  static const backgroundHeight = height * 1.25;

  @override
  Size get preferredSize => const Size.fromHeight(backgroundHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: Colors.transparent,
      toolbarHeight: height,
      centerTitle: centerTitle,
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
