import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/profile/components.dart/backAppBar.dart';
import 'package:podiz/profile/components.dart/buttonFollowing.dart';
import 'package:podiz/profile/components.dart/commentCard.dart';

class ProfilePage extends StatefulWidget {
  static const route = '/profile';
  UserPodiz user;
  ProfilePage(this.user, {Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;
    return Scaffold(
      appBar: BackAppBar(),
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.image_url),
                radius: 50,
              ),

              const SizedBox(height: 12),
              Text(user.name, style: followerName()),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(user.followers.length.toString(),
                      style: followersNumber()),
                  const SizedBox(width: 4),
                  Text("Followers", style: followersText()),
                  const SizedBox(width: 16),
                  Text(user.following.length.toString(),
                      style: followersNumber()),
                  const SizedBox(width: 4),
                  Text("Following", style: followersText()),
                ],
              ),

              user.favPodcasts.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: SizedBox(
                        width: kScreenWidth,
                        child: Text(
                          "${user.name.split(" ")[0]}'s Favorite Podcasts",
                          textAlign: TextAlign.left,
                          style: followersFavorite(),
                        ),
                      ),
                    )
                  : Container(),
              const SizedBox(height: 8),
              user.favPodcasts.isNotEmpty
                  ? SizedBox(
                      height: 68,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children:
                            user.favPodcasts.map(_buildFavouriteItem).toList(),
                      ),
                    )
                  : Container() //change this
            ],
          ),
        ),
        const SizedBox(height: 54),
        user.comments.isNotEmpty
            ? Expanded(
                child: ListView(
                  children: user.comments.reversed.map(_buildItem).toList(),
                ),
              )
            : Container() //change this
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

  Widget _buildItem(Comment c) {
    return CommentCard(c);
  }
}
