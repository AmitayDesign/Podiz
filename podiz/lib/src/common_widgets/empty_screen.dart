import 'package:flutter/material.dart';

class EmptyScreen extends StatelessWidget {
  final Widget child;
  const EmptyScreen({Key? key, required this.child}) : super(key: key);

  factory EmptyScreen.text(String text) => EmptyScreen(
        child: Text(text, textAlign: TextAlign.center),
      );

  factory EmptyScreen.loading() => const EmptyScreen(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: child,
      ),
    );
  }
}

class SliverEmptyScreen extends StatelessWidget {
  final Widget child;
  const SliverEmptyScreen({Key? key, required this.child}) : super(key: key);

  factory SliverEmptyScreen.text(String text) => SliverEmptyScreen(
        child: Text(text, textAlign: TextAlign.center),
      );

  factory SliverEmptyScreen.loading() => const SliverEmptyScreen(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: EmptyScreen(child: child),
    );
  }
}
