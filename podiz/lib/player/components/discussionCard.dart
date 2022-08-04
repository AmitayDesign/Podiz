import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/home/feed/components/buttonPlay.dart';
import 'package:podiz/home/feed/components/cardButton.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/components/profileRow.dart';
import 'package:podiz/player/components/repliesArea.dart';
import 'package:podiz/profile/profilePage.dart';
import 'package:podiz/profile/userManager.dart';

class DiscussionCard extends ConsumerStatefulWidget {
  Comment comment;
  Podcast p;
  final void Function(Comment) onTap;
  DiscussionCard(this.p, this.comment, {Key? key, required this.onTap})
      : super(key: key);

  @override
  ConsumerState<DiscussionCard> createState() => _DiscussionCardState();
}

class _DiscussionCardState extends ConsumerState<DiscussionCard> {
  late ExpandableController controller;

  @override
  void initState() {
    controller = ExpandableController(initialExpanded: true);
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    UserManager userManager = ref.read(userManagerProvider);
    int numberOfReplies =
        ref.read(playerManagerProvider).getNumberOfReplies(widget.comment.id);
    return FutureBuilder(
      future: userManager.getUserFromUid(widget.comment.userUid),
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

            return ExpandableNotifier(
              controller: controller,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  color: theme.colorScheme.surface,
                  width: kScreenWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 9),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleProfile(user: user, size: 20),
                            const SizedBox(
                              width: 8,
                            ),
                            SizedBox(
                              width: 200, //TODO change this!!!
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                            ButtonPlay(widget.p, widget.comment.time),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: kScreenWidth - 28,
                          child: Text(
                            widget.comment.comment,
                            style: discussionCardComment(),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              // decoration: ,
                              width: kScreenWidth - (14 + 16 + 31 + 14),
                              height: 31,
                              child: InkWell(
                                onTap: () => widget.onTap(widget.comment),
                                child: Text("Comment on " +
                                    user.name.split(" ")[0] +
                                    "'s insight..."),
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
                        widget.comment.replies!.isEmpty
                            ? Container()
                            : const Divider(
                                color: Palette.grey800,
                                indent: 0,
                                endIndent: 0,
                                height: 22,
                                thickness: 1,
                              ),
                        widget.comment.replies!.isEmpty
                            ? Container()
                            : ExpandablePanel(
                                controller: controller,
                                collapsed: Column(children: [
                                  // ProfileRow(),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.comment.replies!.entries.first.value
                                        .comment,
                                    maxLines: 1,
                                    style: discussionCardComment(),
                                  ),
                                  const SizedBox(height: 8),
                                  Text("$numberOfReplies more replays...",
                                      style: podcastArtist()),
                                ]),
                                expanded: RepliesArea(
                                    widget.comment.id, widget.comment.replies!, onTap: widget.onTap,),
                                builder: (_, collapsed, expanded) {
                                  return Expandable(
                                      collapsed: collapsed, expanded: expanded);
                                }),
                      ],
                    ),
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
