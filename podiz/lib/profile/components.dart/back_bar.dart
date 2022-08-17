import 'package:flutter/material.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';

class BackBar extends StatelessWidget with PreferredSizeWidget {
  BackBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return const GradientBar(
      automaticallyImplyLeading: false,
      title: BackTextButton(),
    );
  }
}
