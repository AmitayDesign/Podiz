import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/home/feed/components/buttonPlay.dart';
import 'package:podiz/home/feed/components/cardButton.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/player/components/discussionCard.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';

class CommentCard extends ConsumerWidget {
  Comment comment;
  UserPodiz user;
  CommentCard(this.comment, this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    Podcast podcast = ref
        .read(podcastManagerProvider)
        .getPodcastById(comment.uid)
        .searchResultToPodcast();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              PodcastAvatar(imageUrl: podcast.image_url, size: 32),
              const SizedBox(width: 8),
              Container(
                width: 250,
                height: 32,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        podcast.name,
                        style: discussionCardProfile(),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(podcast.show_name,
                            style: discussionAppBarInsights())),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          color: theme.colorScheme.surface,
          width: kScreenWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 9),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleProfile(user: user, size: 20),
                    const SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                      width: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              user.name,
                              style: discussionCardProfile(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text("${user.followers.length} followers",
                                  style: discussionCardFollowers())),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ButtonPlay(comment.uid, comment.time),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: kScreenWidth - 32,
                  child: Text(
                    comment.comment,
                    style: discussionCardComment(),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: kScreenWidth - (16 + 20 + 16 + 16),
                      height: 31,
                      child: TextField(
                        // controller: commentController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            hintText: "Comment on " +
                                user.name.split(" ")[0] +
                                "'s insight..."), //TODO change this
                      ),
                    ),
                    const Spacer(),
                    CardButton(
                      const Icon(
                        Icons.share,
                        color: Color(0xFF9E9E9E),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
