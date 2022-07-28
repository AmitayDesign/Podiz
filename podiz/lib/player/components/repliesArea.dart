import 'package:flutter/material.dart';
import 'package:podiz/objects/Comment.dart';

class RepliesArea extends StatelessWidget {
  Map<String, Comment> replies;
  RepliesArea(this.replies, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Comment> list = [];
    replies.forEach((key, value) => list.add(value));
    //number of comments!
    //expansion tile maybe
    return Container( height: 50, child: Text(list[0].comment),);
  }
}
