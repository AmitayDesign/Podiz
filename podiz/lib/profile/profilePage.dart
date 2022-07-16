import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/home/components/followShowButton.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/profile/components.dart/backAppBar.dart';
import 'package:podiz/profile/components.dart/commentCard.dart';
import 'package:podiz/profile/components.dart/followPeopleButton.dart';

class ProfilePage extends ConsumerWidget {
  static const route = '/profile';
  UserPodiz user;
  ProfilePage(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    ShowManager showManager = ref.read(showManagerProvider);
    AuthManager authManager = ref.read(authManagerProvider);

    return Scaffold(
      appBar: BackAppBar(),
      floatingActionButton: authManager.userBloc!.uid != user.uid ? FollowPeopleButton(user): Container(),
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
                        children: user.favPodcasts
                            .map((show) => _buildFavouriteItem(
                                showManager.getShowImageUrl(show)))
                            .toList(),
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

  Widget _buildFavouriteItem(String url) {
    return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: PodcastAvatar(imageUrl: url, size: 68));
  }

  Widget _buildItem(Comment c) {
    return CommentCard(c);
  }
}
