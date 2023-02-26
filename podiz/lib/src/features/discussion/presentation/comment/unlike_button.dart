import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:podiz/src/theme/context_theme.dart';

class UnlikeButton extends StatelessWidget {
  final double size;
  final Color? color;
  final VoidCallback? onPressed;
  final bool? like;
  final int? number;

  const UnlikeButton(
      {Key? key,
      this.size = 60,
      this.color,
      this.onPressed,
      this.like,
      this.number})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: const Size(50, 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/icons/unlike.svg"),
            const SizedBox(width: 4),
            Text(
              number.toString(),
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
