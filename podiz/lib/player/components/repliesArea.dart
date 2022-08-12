import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/widgets/cardButton.dart';
import 'package:podiz/aspect/widgets/shimmerLoading.dart';
import 'package:podiz/home/components/replyView.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/player/components/profileRow.dart';
import 'package:podiz/profile/userManager.dart';

class RepliesArea extends ConsumerWidget {
  final String commentUid;
  final Map<String, Comment> replies;
  const RepliesArea(this.commentUid, this.replies, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Comment> list = [];
    replies.forEach((key, value) => list.add(value));
    List<Widget> treeWidget = [];
    replies.forEach((key, commentlvl2) {
      treeWidget
          .add(elementOfTree(commentlvl2, commentlvl2.lvl - 1, ref, context));
    });
    return Column(children: treeWidget);
  }

  Widget commentButton(
      Comment c, int lvl, UserPodiz user, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Palette.grey900,
          ),
          width: kScreenWidth - (14 + lvl * (23 + 8) + 16 + 31 + 14),
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
                      padding: MediaQuery.of(context).viewInsets,
                      child: ReplyView(comment: c, user: user),
                    )),
            child: Text("Comment on ${user.name.split(" ")[0]}'s insight..."),
          ),
        ),
        const SizedBox(width: 16),
        const CardButton(
          Icon(
            Icons.share,
            color: Color(0xFF9E9E9E),
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget elementOfTree(
      Comment c, int lvl, WidgetRef ref, BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder(
      future: ref.read(userManagerProvider).getUserFromUid(c.userUid),
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

            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ProfileRow(user),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        const VerticalDivider(
                            width: 23,
                            thickness: 1,
                            indent: 4,
                            endIndent: 4,
                            color: Palette.grey600),
                        const SizedBox(width: 8),
                        LimitedBox(
                          maxWidth: kScreenWidth - (14 + lvl * (23 + 8) + 14),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    c.comment,
                                    style: context.textTheme.bodyLarge,
                                  ),
                                ),
                              ),
                              if (lvl == 3) ...[
                                Container(),
                              ] else ...[
                                const SizedBox(height: 8),
                                commentButton(c, lvl, user, context),
                                const SizedBox(height: 16),
                                for (var key in c.replies!.keys)
                                  elementOfTree(
                                      c.replies![key]!, lvl + 1, ref, context)
                              ]
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ]);
          }
        }
        return ShimmerLoading(
          child: Container(
            color: theme.colorScheme.surface,
            width: kScreenWidth,
            height: 50,
          ),
        );
      },
    );
  }
}
