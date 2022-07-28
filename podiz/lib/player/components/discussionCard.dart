import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/home/feed/components/buttonPlay.dart';
import 'package:podiz/home/feed/components/cardButton.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/player/components/repliesArea.dart';
import 'package:podiz/profile/profilePage.dart';
import 'package:podiz/profile/userManager.dart';

class DiscussionCard extends ConsumerWidget {
  //TODO change this to widget
  Comment comment;
  Podcast podcast;
  DiscussionCard(this.podcast, this.comment, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    UserManager userManager = ref.read(userManagerProvider);
    return FutureBuilder(
      future: userManager.getUserFromUid(comment.uid),
      initialData: "loading",
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If we got an error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error} occurred',
                style: TextStyle(fontSize: 18),
              ),
            );

            // if we got our data
          } else if (snapshot.hasData) {
            final user = snapshot.data as UserPodiz;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                color: theme.colorScheme.surface,
                width: kScreenWidth,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14.0, vertical: 9),
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
                                    child: Text(
                                        "${user.followers.length} followers",
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
                            width: kScreenWidth - (16 + 20+ 16 +16 ),
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
                      comment.replies!.isEmpty
                          ? Container()
                          : RepliesArea(comment.replies!),
                    ],
                  ),
                ),
              ),
            );
          }
        }
        return Container(
            color: theme.colorScheme.surface,
            width: kScreenWidth,
            height: 50,
            );
      },
    );
  }
}
