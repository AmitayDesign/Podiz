import 'package:flutter/material.dart';
import 'package:podiz/src/theme/context_theme.dart';

class FeedTitle extends StatelessWidget {
  final String text;
  final Key? textKey;
  const FeedTitle(this.text, {Key? key, this.textKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8)
          .add(const EdgeInsets.symmetric(horizontal: 16)),
      child: Text(text, style: context.textTheme.bodyLarge, key: textKey),
    );
  }
}

/// Sliver version of [FeedTitle]
class SliverFeedTitle extends StatelessWidget {
  final String text;
  final Key? textKey;
  const SliverFeedTitle(this.text, {Key? key, this.textKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FeedTitle(text, textKey: textKey),
    );
  }
}
