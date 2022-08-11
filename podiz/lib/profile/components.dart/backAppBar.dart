import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/appBarGradient.dart';

class BackAppBar extends StatelessWidget with PreferredSizeWidget {
  BackAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          height: 100,
          decoration: BoxDecoration(gradient: appBarGradient()),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 30),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Row(children: [
                const Icon(
                  Icons.arrow_back_ios_new,
                  size: 15,
                  color: Color(0xB2FFFFFF),
                ),
                const SizedBox(width: 10),
                Text(
                  Locales.string(context, "back"),
                  style: context.textTheme.bodyMedium,
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
