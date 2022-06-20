import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/profile/components.dart/backAppBar.dart';
import 'package:podiz/profile/components.dart/buttonFollowing.dart';
import 'package:podiz/profile/components.dart/followersCard.dart';

class FollowerProfilePage extends StatefulWidget {
  static const route = '/followerProfile';
  FollowerProfilePage({Key? key}) : super(key: key);

  @override
  State<FollowerProfilePage> createState() => _FollowerProfilePageState();
}

class _FollowerProfilePageState extends State<FollowerProfilePage> {
  List<String> favorite_posts = ["1", "2", "3", "4"];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: BackAppBar(),
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.primaryColor,
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: ButtonFollowing(),
                  )
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                  width: kScreenWidth,
                  child: Text(
                    "Jenifer Lewis",
                    style: followerName(),
                    textAlign: TextAlign.left,
                  )),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text("31", style: followersNumber()),
                  const SizedBox(width: 4),
                  Text("Followers", style: followersText()),
                  const SizedBox(width: 16),
                  Text("12", style: followersNumber()),
                  const SizedBox(width: 4),
                  Text("Following", style: followersText()),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                  width: kScreenWidth,
                  child: Text("Jeniffer's Favorite Podcasts",
                      textAlign: TextAlign.left, style: followersFavorite())),
              const SizedBox(height: 8),
              Container(
                height: 68,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: favorite_posts.map(_buildFavouriteItem).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 54),
        Expanded(
          child: ListView(
            children: favorite_posts.map(_buildItem).toList(),
          ),
        ),
      ]),
    );
  }

  Widget _buildFavouriteItem(String e) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        height: 68,
        width: 68,
        decoration: BoxDecoration(
            color: Color(0xFF6310BF), borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  Widget _buildItem(String e) {
    return FollowersCard();
  }
}
