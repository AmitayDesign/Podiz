import 'package:flutter/material.dart';

class PlayerButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;
  final Widget icon;
  const PlayerButton({
    Key? key,
    this.loading = false,
    required this.onPressed,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: loading ? null : () => onPressed(),
      icon: icon,
    );
  }
}
