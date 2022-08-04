import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/profile/userManager.dart';

class ReplyView extends ConsumerWidget {
  Comment comment;
  final void Function() onTap;
  FocusNode focusNode;
  TextEditingController controller;
  ReplyView({
    Key? key,
    required this.comment,
    required this.onTap,
    required this.focusNode,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return FutureBuilder(
      future: ref.read(userManagerProvider).getUserFromUid(comment.userUid),
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
            return Container(
              width: kScreenWidth,
              decoration: const BoxDecoration(
                color: Color(0xFF4E4E4E),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Replying to...",
                        style: podcastInsightsQuickNote(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleProfile(user: user, size: 20),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            Text(
                              user.name,
                              style: discussionCardProfile(),
                            ),
                            Text("${user.followers.length} Followers",
                                style: discussionCardFollowers()),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(comment.comment,
                            style: discussionCardComment())),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleProfile(user: user, size: 15.5),
                        const SizedBox(width: 8),
                        LimitedBox(
                          maxWidth: kScreenWidth - (14 + 31 + 8 + 31 + 8 + 14),
                          maxHeight: 31,
                          child: TextField(
                            // key: _key,
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            focusNode: focusNode,
                            controller: controller,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF262626),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              hintStyle: discussionSnackCommentHint(),
                              hintText: "Comment on ${user.name} insight...",
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: onTap,
                          child: Container(
                            height: 31,
                            width: 31,
                            decoration: BoxDecoration(
                              color: Palette.darkPurple,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.send,
                              size: 11,
                              color: Palette.pureWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            );
          }
        }
        return Container(
          width: kScreenWidth,
          height: 50,
          decoration: const BoxDecoration(
            color: Color(0xFF4E4E4E),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}