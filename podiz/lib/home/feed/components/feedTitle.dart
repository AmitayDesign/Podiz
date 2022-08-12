import 'package:flutter/material.dart';
import 'package:podiz/aspect/extensions.dart';

class FeedTile extends StatelessWidget {
  final String text;
  final Key? textKey;
  const FeedTile(this.text, {Key? key, this.textKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8)
          .add(const EdgeInsets.symmetric(horizontal: 8)),
      child: Text(text, style: context.textTheme.bodyLarge, key: textKey),
    );
  }
}

/// Sliver version of [FeedTitle]
class SliverFeedTile extends StatelessWidget {
  final String text;
  final Key? textKey;
  const SliverFeedTile(this.text, {Key? key, this.textKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8)
            .add(const EdgeInsets.symmetric(horizontal: 8)),
        child: Text(text, style: context.textTheme.bodyLarge, key: textKey),
      ),
    );
  }
}
