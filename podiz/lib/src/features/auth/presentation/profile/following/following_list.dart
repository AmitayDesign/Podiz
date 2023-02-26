import 'package:flutter/material.dart';
import 'package:podiz/src/features/auth/presentation/profile/following/following_tile.dart';

class FollowingList extends StatefulWidget {
  const FollowingList(this.users, {Key? key}) : super(key: key);

  final List<String> users;
  @override
  State<FollowingList> createState() => _FollowingList();
}

class _FollowingList extends State<FollowingList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.users.length,
      itemBuilder: (context, index) => FollowingTile(widget.users[index]),
    );
  }
}
