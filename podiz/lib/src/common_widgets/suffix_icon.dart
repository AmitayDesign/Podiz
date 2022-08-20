import 'package:flutter/material.dart';
import 'package:podiz/src/constants/constants.dart';

class SuffixIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const SuffixIcon(this.icon, {Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Icon(icon, size: kSmallIconSize),
      ),
    );
  }
}
