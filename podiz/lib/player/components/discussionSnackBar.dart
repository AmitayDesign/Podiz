import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/components/pinkTimer.dart';
import 'package:podiz/providers.dart';

class DiscussionSnackBar extends ConsumerStatefulWidget {
  Player player;
  DiscussionSnackBar(this.player, {Key? key}) : super(key: key);

  @override
  ConsumerState<DiscussionSnackBar> createState() => _DiscussionSnackBarState();
}

class _DiscussionSnackBarState extends ConsumerState<DiscussionSnackBar> {
  final TextEditingController _controller = TextEditingController();

  bool visible = false;

  final Key _key = const Key("textField");

  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    _controller.dispose();
  }

  // @override
  // void didUpdateWidget(DiscussionSnackBar oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    print("building");
    return Container(
        height: 127,
        decoration: const BoxDecoration(
          color: Color(0xFF4E4E4E),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        child: visible
            ? openedTextInputView(context)
            : closedTextInputView(context));
  }

  Widget openedTextInputView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 20),
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
                  ref.read(playerManagerProvider).resumeEpisode();
                  ref.read(authManagerProvider).doComment(
                      _controller.text,
                      ref.read(playerProvider).podcastPlaying!.uid!,
                      ref.read(playerProvider).position.inMilliseconds);
                    
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
          const SizedBox(height: 24),
          Row(
            children: [
              // StackedImages(23), //TODO change this
              const SizedBox(width: 8),
              Text(
                "8 listening with you", //TODO change this!!!
                style: discussionAppBarInsights(),
              ),
              const Spacer(),
              const Icon(
                Icons.pause,
                size: 25,
              ),
              const SizedBox(width: 15),
              PinkTimer(),
              const SizedBox(width: 15),
              const Icon(
                Icons.rotate_90_degrees_cw_outlined,
                size: 25,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget closedTextInputView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Column(
        children: [
          Row(
            children: [
              // StackedImages(23), TODO change this
              const SizedBox(width: 8),
              Text(
                "8 listening with you", //TODO change this!!!
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
                child: Container(
                    width: 226,
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
              Spacer(),
              const Icon(
                Icons.rotate_90_degrees_ccw_outlined,
                size: 25,
              ),
              const SizedBox(width: 25),
              const Icon(
                Icons.pause, //TODO change this
                size: 25,
              ),
              const SizedBox(width: 25),
              const Icon(
                Icons.rotate_90_degrees_cw_outlined,
                size: 25,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
