import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  final Widget icon;
  const CardButton(this.icon, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 31,
      height: 31,
      decoration: BoxDecoration(
        color: const Color(0xFF040404),
        borderRadius: BorderRadius.circular(30),
      ),
      child: icon,
    );
  }
}
