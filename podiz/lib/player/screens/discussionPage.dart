import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/shimmerLoading.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/components/discussionAppBar.dart';
import 'package:podiz/player/components/discussionCard.dart';
import 'package:podiz/player/components/discussionSnackBar.dart';
import 'package:podiz/profile/userManager.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class DiscussionPage extends ConsumerStatefulWidget {
  static const route = '/discussionPage';
  DiscussionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends ConsumerState<DiscussionPage> {
  Duration position = Duration.zero;
  StreamSubscription<Duration>? subscription;
  late String episodeUid;

  final TextEditingController controller = TextEditingController();
  bool visible = false;
  bool isComment = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    var player = ref.read(playerProvider);
    position = player.timer.position;
    final playerManager = ref.read(playerManagerProvider);

    subscription = player.timer.onAudioPositionChanged.listen((newPosition) {
      position = newPosition;
      playerManager.showComments(position.inMilliseconds);
    });
    super.initState();
  }

  @override
  void dispose() {
    subscription!.cancel();
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  Comment? commentToReply;

  void onTap(Comment c) {
    setState(() {
      focusNode.requestFocus();
      commentToReply = c;
      isComment = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsStreamProvider);
    final podcast = ref.watch(podcastProvider);
    return comments.maybeWhen(
      data: (c) {
        return podcast.maybeWhen(
          data: (p) => GestureDetector(
            onTap: (() => setState(
                  () {
                    visible = false;
                    focusNode.unfocus();
                    isComment = false;
                  },
                )),
            child: Scaffold(
              appBar: DiscussionAppBar(p),
              body: Column(children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: c.length,
                    itemBuilder: (context, index) =>
                        DiscussionCard(p, c[index], onTap: onTap),
                  ),
                ),
                isComment
                    ? replyView()
                    : DiscussionSnackBar(p,
                        visible: visible,
                        focusNode: focusNode,
                        controller: controller)
              ]),
            ),
          ),
          loading: () => Scaffold(
            body: Column(children: [
              Spacer(),
              ShimmerLoading(
                child: Container(
                  width: kScreenWidth,
                  height: 127,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4E4E4E),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                ),
              )
            ]),
          ),
          orElse: () => SplashScreen.error(),
        );
      },
      loading: () => Scaffold(
        body: Column(children: [
          Spacer(),
          ShimmerLoading(
            child: Container(
              width: kScreenWidth,
              height: 127,
              decoration: const BoxDecoration(
                color: Color(0xFF4E4E4E),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
            ),
          )
        ]),
      ),
      orElse: () => SplashScreen.error(),
    );
  }

  Widget replyView() {
    return FutureBuilder(
      future:
          ref.read(userManagerProvider).getUserFromUid(commentToReply!.userUid),
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
                        child: Text(commentToReply!.comment,
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
                          onTap: () {
                            ref
                                .read(authManagerProvider)
                                .doReply(commentToReply!, controller.text);
                            setState(() {
                              commentToReply = null;
                              isComment = false;
                              controller.clear();
                            });
                          },
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
