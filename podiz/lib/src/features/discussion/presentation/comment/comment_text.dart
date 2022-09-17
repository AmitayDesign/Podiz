import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/utils/open_url.dart';

class CommentText extends StatelessWidget {
  final String text;
  const CommentText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Linkify(
      options: const LinkifyOptions(removeWww: true),
      onOpen: (link) => openUrl(link.url),
      text: text,
      style: context.textTheme.bodyLarge,
    );
  }
}
