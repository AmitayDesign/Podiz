import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/player/PlayerManager.dart';

class RepliesArea extends ConsumerWidget {
  String commentUid;
  Map<String, Comment> replies;
  RepliesArea(this.commentUid, this.replies, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Comment> list = [];
    replies.forEach((key, value) => list.add(value));
    int numberOfReplies =
        ref.read(playerManagerProvider).getNumberOfReplies(commentUid);
    return Container(
      height: 50,
      child: Text(numberOfReplies.toString()),
    );
  }
}
