import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/authentication/auth_manager.dart';
import 'package:podiz/home/components/profileAvatar.dart';
import 'package:podiz/home/feed/components/commentSheet.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/PlayerManager.dart';
import 'package:podiz/player/components/pinkTimer.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class DiscussionSnackBar extends ConsumerStatefulWidget {
  final Podcast p;
  const DiscussionSnackBar(
    this.p, {
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<DiscussionSnackBar> createState() => _DiscussionSnackBarState();
}

class _DiscussionSnackBarState extends ConsumerState<DiscussionSnackBar> {
  late String episodeUid;
  bool firstTime = true;
  // final Key _key = const Key("textField");

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    if (firstTime) {
      episodeUid = widget.p.uid!;
      player.increment(episodeUid);
      firstTime = false;
    }
    return Container(
        height: 127,
        decoration: const BoxDecoration(
          color: Color(0xFF4E4E4E),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        child: closedTextInputView(context, widget.p));
  }

  Widget closedTextInputView(BuildContext context, Podcast episode) {
    final playerManager = ref.watch(playerManagerProvider);
    final state = ref.watch(stateProvider);
    return state.when(
        error: (e, _) {
          print('discussionSnackBar: ${e.toString()}');
          return SplashScreen.error();
        },
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
                      style: context.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    const PinkTimer(),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        ref.read(playerManagerProvider).pauseEpisode();
                        showModalBottomSheet(
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
                            child: CommentSheet(
                              podcast: widget.p,
                            ),
                          ),
                        );
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
                                style: context.textTheme.bodyMedium!.copyWith(
                                  color: Palette.white90,
                                ),
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
