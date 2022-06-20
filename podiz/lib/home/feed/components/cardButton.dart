import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  Widget icon;
  CardButton(this.icon,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 31,
      height: 31,
      decoration:BoxDecoration(
        color: Color(0xFF040404),
        borderRadius: BorderRadius.circular(30),
      ),
      child: icon,
    );
  }
}