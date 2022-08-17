import 'package:flutter/material.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/src/theme/palette.dart';

class ReplyButton extends StatelessWidget {
  final double size;
  final VoidCallback? onPressed;
  final String? text;

  const ReplyButton({
    Key? key,
    this.size = 32,
    this.onPressed,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size.fromHeight(size),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Palette.grey900,
          elevation: 0,
          shape: const StadiumBorder(),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: onPressed,
        child: Text(
          text ?? 'Add a reply...',
          style: context.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
