import 'package:flutter/material.dart';
import 'package:podiz/home/feed/components/discussionAppBar.dart';
import 'package:podiz/home/feed/components/discussionCard.dart';
import 'package:podiz/home/feed/components/discussionSnackBar.dart';

class DiscussionPage extends StatefulWidget {
  DiscussionPage({Key? key}) : super(key: key);
  static const route = '/discussion';

  @override
  State<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  List<String> posts = ["1", "2", "3", "4", "5"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DiscussionAppBar(),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) => DiscussionCard(),
          ),
        ),
        DiscussionSnackBar(),
      ]),
    );
  }
}
