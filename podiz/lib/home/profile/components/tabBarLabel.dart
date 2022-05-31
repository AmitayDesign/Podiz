import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class TabBarLabel extends StatelessWidget {
  String text;
  TabBarLabel(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey),
      ),
      width: 130,
      height: 40,
      child: Tab(
        child: Center(
          child: Text(
            Locales.string(context, text),
          ),
        ),
      ),
    );
  }
}
