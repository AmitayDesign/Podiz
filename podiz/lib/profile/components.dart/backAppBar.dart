import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/appBarGradient.dart';

class BackAppBar extends StatelessWidget with PreferredSizeWidget {
  BackAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      automaticallyImplyLeading: false,
      title: const BackAppBarButton(),
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: appBarGradient()),
      ),
    );
  }
}

class BackAppBarButton extends StatelessWidget {
  const BackAppBarButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: Navigator.of(context).pop,
      label: Text(
        Locales.string(context, "back"),
        style: context.textTheme.bodyMedium,
      ),
      icon: const Icon(
        Icons.arrow_back_ios_new,
        size: 12,
        color: Color(0xB2FFFFFF),
      ),
    );
  }
}
