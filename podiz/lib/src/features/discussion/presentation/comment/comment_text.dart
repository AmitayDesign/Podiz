import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CommentText extends StatelessWidget {
  final String text;
  const CommentText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Linkify(
      options: const LinkifyOptions(removeWww: true),
      onOpen: (link) async {
        if (await canLaunchUrlString(link.url)) {
          await launchUrlString(link.url);
        }
      },
      text: text,
      style: context.textTheme.bodyLarge,
    );
  }
}
