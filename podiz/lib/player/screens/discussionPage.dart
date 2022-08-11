import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/widgets/shimmerLoading.dart';
import 'package:podiz/authentication/authManager.dart';
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
  const DiscussionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends ConsumerState<DiscussionPage> {
  late StreamSubscription<Duration> subscription;
  late String episodeUid;

  final TextEditingController controller = TextEditingController();
  bool visible = false;
  bool isComment = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    var player = ref.read(playerProvider);
    subscription = player.timer.onAudioPositionChanged.listen((position) {
      final playerManager = ref.read(playerManagerProvider);
      playerManager.showComments(position.inMilliseconds);
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  Comment? commentToReply;

  void onTap(Comment c) {
    setState(() {
      commentToReply = c;
      isComment = true;
    });
    focusNode.requestFocus();
  }

  Widget get loadingWidget => Column(children: [
        const Spacer(),
        ShimmerLoading(
          child: Container(
            width: kScreenWidth,
            height: 127,
            decoration: const BoxDecoration(
              color: Color(0xFF4E4E4E),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
          ),
        )
      ]);

  @override
  Widget build(BuildContext context) {
    final commentsValue = ref.watch(commentsStreamProvider);
    final podcastValue = ref.watch(playerPodcastProvider);
    return Scaffold(
      appBar: DiscussionAppBar(podcastValue.valueOrNull),
      body: podcastValue.when(
          error: (e, _) {
            print('discussionPage: ${e.toString()}');
            return SplashScreen.error();
          },
          loading: () => loadingWidget,
          data: (podcast) {
            return commentsValue.when(
                error: (e, _) {
                  print('discussionPage: ${e.toString()}');
                  return SplashScreen.error();
                },
                loading: () => loadingWidget,
                data: (comments) {
                  return Column(children: [
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return DiscussionCard(
                            podcast,
                            comments[index],
                            onTap: onTap,
                          );
                        },
                      ),
                    ),
                    isComment
                        ? replyView()
                        : DiscussionSnackBar(
                            podcast,
                            visible: visible,
                            focusNode: focusNode,
                            controller: controller,
                          )
                  ]);
                });
          }),
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
                style: const TextStyle(fontSize: 18),
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
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: Palette.grey600,
                        ),
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
                              style: context.textTheme.titleMedium,
                            ),
                            Text(
                              "${user.followers.length} Followers",
                              style: context.textTheme.bodyMedium!.copyWith(
                                color: Palette.grey600,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        commentToReply!.comment,
                        style: context.textTheme.bodyLarge,
                      ),
                    ),
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
                              hintStyle: context.textTheme.bodyMedium,
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
          child: const CircularProgressIndicator(),
        );
      },
    );
  }
}
