import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/buttonPlay.dart';
import 'package:podiz/aspect/widgets/cardButton.dart';
import 'package:podiz/home/components/replyView.dart';
import 'package:podiz/player/components/repliesArea.dart';
import 'package:podiz/profile/userManager.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/discussion/domain/comment.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/theme/palette.dart';

// https://pub.dev/packages/flutter_linkify

class DiscussionCard extends ConsumerStatefulWidget {
  final Comment comment;
  final Episode episode;

  const DiscussionCard(this.episode, this.comment, {Key? key})
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
    UserManager userManager = ref.watch(userManagerProvider);
    // final numberOfReplies =
    //     ref.read(playerRepositoryProvider).getNumberOfReplies(widget.comment.id);
    return FutureBuilder(
      future: userManager.getUserFromUid(widget.comment.userId),
      initialData: "loading",
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If we got an error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error} occurred',
                style: const TextStyle(fontSize: 18),
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
                            UserAvatar(user: user, radius: 20),
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
                                      style: context.textTheme.titleMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "${user.followers.length} followers",
                                      style: context.textTheme.bodyMedium!
                                          .copyWith(
                                        color: Palette.grey600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            ButtonPlay(widget.episode, widget.comment.time),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: kScreenWidth - 28,
                          child: Text(
                            widget.comment.text,
                            style: context.textTheme.bodyLarge,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Palette.grey900,
                              ),
                              width: kScreenWidth - (14 + 16 + 31 + 14),
                              height: 31,
                              child: InkWell(
                                onTap: () => showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Palette.grey900,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(kBorderRadius),
                                      ),
                                    ),
                                    builder: (context) => Padding(
                                          padding:
                                              MediaQuery.of(context).viewInsets,
                                          child: ReplyView(
                                              comment: widget.comment,
                                              user: user),
                                        )),
                                child: Text(
                                    "Comment on ${user.name.split(" ")[0]}'s insight..."),
                              ),
                            ),
                            const Spacer(),
                            const CardButton(
                              Icon(
                                Icons.share,
                                color: Color(0xFF9E9E9E),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        widget.comment.replies.isEmpty
                            ? Container()
                            : const Divider(
                                color: Palette.grey800,
                                indent: 0,
                                endIndent: 0,
                                height: 22,
                                thickness: 1,
                              ),
                        widget.comment.replies.isEmpty
                            ? Container()
                            :
                            // ExpandablePanel(
                            //     // TODO this
                            //     controller: controller,
                            //     collapsed: Column(children: [
                            //       // ProfileRow(),
                            //       const SizedBox(height: 4),
                            //       Text(
                            //         widget.comment.replies!.entries.first.value
                            //             .comment,
                            //         maxLines: 1,
                            //         style: discussionCardComment(),
                            //         overflow: TextOverflow.ellipsis,
                            //       ),
                            //       const SizedBox(height: 8),
                            //       Text("$numberOfReplies more replays...",
                            //           style: podcastArtist()),
                            //     ]),
                            //     expanded:
                            RepliesArea(
                                widget.comment.id,
                                widget.comment.replies,
                              ),
                        // builder: (_, collapsed, expanded) {
                        //   return Expandable(
                        //       collapsed: collapsed, expanded: expanded);
                        // }),
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
