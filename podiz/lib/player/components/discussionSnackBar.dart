import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/shimmerLoading.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/components/pinkTimer.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class DiscussionSnackBar extends ConsumerStatefulWidget {
  DiscussionSnackBar({Key? key}) : super(key: key);

  @override
  ConsumerState<DiscussionSnackBar> createState() => _DiscussionSnackBarState();
}

class _DiscussionSnackBarState extends ConsumerState<DiscussionSnackBar> {
  final TextEditingController _controller = TextEditingController();

  bool visible = false;

  bool firstTime = true;
  late String episodeUid;

  final Key _key = const Key("textField");

  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    FirebaseFirestore.instance
        .collection("podcasts")
        .doc(episodeUid)
        .update({"watching": FieldValue.increment(-1)});
    focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  // @override
  // void didUpdateWidget(DiscussionSnackBar oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final podcast = ref.watch(podcastProvider);
    return podcast.maybeWhen(
        orElse: () => SplashScreen.error(),
        loading: () => ShimmerLoading(
              child: Container(
                height: 127,
                width: kScreenWidth,
                decoration: const BoxDecoration(
                  color: Color(0xFF4E4E4E),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
              ),
            ),
        data: (p) {
          final player = ref.read(playerProvider);
          if (firstTime) {
            episodeUid = p.uid!;
            player.increment(episodeUid);
            firstTime = false;
          }
          return Container(
              height: 127,
              decoration: const BoxDecoration(
                color: Color(0xFF4E4E4E),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
              child: visible
                  ? openedTextInputView(context, p)
                  : closedTextInputView(context, p));
        });
  }

  Widget openedTextInputView(BuildContext context, Podcast episode) {
    final playerManager = ref.read(playerManagerProvider);
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14, top: 20, bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              CircleProfile(
                user: ref.read(authManagerProvider).userBloc!,
                size: 15.5,
              ),
              const SizedBox(width: 8),
              LimitedBox(
                maxWidth: kScreenWidth - (14 + 31 + 8 + 31 + 8 + 14),
                maxHeight: 31,
                child: TextField(
                  // key: _key,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  focusNode: focusNode,
                  controller: _controller,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF262626),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    hintStyle: discussionSnackCommentHint(),
                    hintText: "Share your insight...",
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  ref.read(playerManagerProvider).resumeEpisode(episode);
                  ref.read(authManagerProvider).doComment(
                      _controller.text,
                      ref.read(playerProvider).podcastPlaying!.uid!,
                      ref.read(playerProvider).timer.position.inMilliseconds);

                  setState(() {
                    visible = false;
                  });
                  focusNode.unfocus();
                  _controller.clear();
                },
                child: const Icon(
                  Icons.send,
                  size: 31,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // StackedImages(23), //TODO change this
              const SizedBox(width: 8),
              Text(
                "${episode.watching} listening with you", //TODO change this!!!
                style: discussionAppBarInsights(),
              ),
              const Spacer(),

              IconButton(
                onPressed: () => playerManager.play30Back(episode),
                icon: const Icon(
                  Icons.rotate_90_degrees_ccw_outlined,
                  size: 25,
                ),
              ),
              const SizedBox(width: 15),
              PinkTimer(),
              const SizedBox(width: 15),
              IconButton(
                onPressed: () => playerManager.play30Up(episode),
                icon: const Icon(
                  Icons.rotate_90_degrees_cw_outlined,
                  size: 25,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget closedTextInputView(BuildContext context, Podcast episode) {
    final playerManager = ref.read(playerManagerProvider);
    final state = ref.watch(stateProvider);
    return state.maybeWhen(
        orElse: () => SplashScreen.error(),
        loading: () => Container(
              height: 127,
              decoration: const BoxDecoration(
                color: Color(0xFF4E4E4E),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
              child: const CircularProgressIndicator(),
            ),
        data: (s) {
          final icon = s == PlayerState.play ? Icons.stop : Icons.play_arrow;
          final onTap = s == PlayerState.play
              ? () => playerManager.pauseEpisode()
              : () => playerManager.resumeEpisode(episode);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    // StackedImages(23), TODO change this
                    const SizedBox(width: 8),
                    Text(
                      "${episode.watching} listening with you", //TODO change this!!!
                      style: discussionAppBarInsights(),
                    ),
                    Spacer(),
                    PinkTimer(),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        ref.read(playerManagerProvider).pauseEpisode();
                        setState(() {
                          visible = true;
                        });
                        focusNode.requestFocus();
                      },
                      child: LimitedBox(
                        maxWidth: kScreenWidth - (16 + 90 + 16),
                        child: Container(
                            height: 33,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: const Color(0xFF262626),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Share your insight...",
                                style: discussionSnackCommentHint(),
                              ),
                            )),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => playerManager.play30Back(episode),
                        icon: const Icon(
                          Icons.rotate_90_degrees_ccw_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(icon),
                        onPressed: onTap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => playerManager.play30Up(episode),
                        icon: const Icon(
                          Icons.rotate_90_degrees_cw_outlined,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        });
  }
}
