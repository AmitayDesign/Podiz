import 'package:flutter/material.dart';

class EmptyScreen extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Widget child;
  const EmptyScreen({Key? key, required this.child, this.padding})
      : super(key: key);

  factory EmptyScreen.text(String text, {EdgeInsetsGeometry? padding}) =>
      EmptyScreen(
        padding: padding,
        child: Text(text, textAlign: TextAlign.center),
      );

  factory EmptyScreen.loading({EdgeInsetsGeometry? padding}) => EmptyScreen(
        padding: padding,
        child: const SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16)
          .add(padding ?? EdgeInsets.zero),
      child: child,
    );
  }
}
