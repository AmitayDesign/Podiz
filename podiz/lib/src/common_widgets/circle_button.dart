import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';

class CircleButton extends StatelessWidget {
  final double size;
  final Color? color;
  final VoidCallback? onPressed;
  final IconData icon;

  const CircleButton({
    Key? key,
    this.size = 40,
    this.color,
    this.onPressed,
    required this.icon,
  }) : super(key: key);

  static const defaultSize = 40.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: color,
          elevation: 0,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Icon(icon, size: kSmallIconSize),
      ),
    );
  }
}
