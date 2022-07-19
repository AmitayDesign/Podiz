import 'package:flutter/material.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/stackedImages.dart';
import 'package:podiz/objects/user/Player.dart';

class DiscussionSnackBar extends StatefulWidget {
  Player player;
  DiscussionSnackBar(this.player, {Key? key}) : super(key: key);

  @override
  State<DiscussionSnackBar> createState() => _DiscussionSnackBarState();
}

class _DiscussionSnackBarState extends State<DiscussionSnackBar> {
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    position = widget.player.position;
    widget.player.onAudioPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 121,
      decoration: const BoxDecoration(
        color: Color(0xFF4E4E4E),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Padding(
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
                Container(
                  child: Center(
                    child: Text(
                      timePlayerFormatter(
                          widget.player.position.inMilliseconds),
                      style: discussionSnackPlay(),
                    ),
                  ),
                  width: 64,
                  height: 23,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color(0xFFD74EFF)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 226,
                  height: 33,
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFF262626),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      hintStyle: discussionSnackCommentHint(),
                      hintText: "Share your insight...",
                    ),
                  ),
                ),
                Spacer(),
                const Icon(
                  Icons.rotate_90_degrees_ccw_outlined,
                  size: 25,
                ),
                const SizedBox(width: 25),
                const Icon(
                  Icons.pause,
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
      ),
    );
  }
}
