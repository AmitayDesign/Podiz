import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class BackTextButton extends StatelessWidget {
  const BackTextButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: Navigator.of(context).pop,
      label: Text(
        Locales.string(context, "back"),
        style: const TextStyle(color: Colors.white70),
      ),
      icon: const Icon(
        Icons.arrow_back_ios_new,
        size: 12,
        color: Color(0xB2FFFFFF),
      ),
    );
  }
}
