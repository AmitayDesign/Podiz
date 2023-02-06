import 'package:flutter/material.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';
import 'package:video_player/video_player.dart';

class WalkthroughStep extends StatefulWidget {
  final String title;
  final String boldTitle;
  final List<String> emojis;
  final List<String> texts;
  final String videoPath;

  const WalkthroughStep({
    Key? key,
    required this.title,
    required this.boldTitle,
    required this.emojis,
    required this.texts,
    required this.videoPath,
  })  : assert(emojis.length == texts.length),
        super(key: key);

  @override
  State<WalkthroughStep> createState() => _WalkthroughStepState();
}

class _WalkthroughStepState extends State<WalkthroughStep> {
  late final videoController = VideoPlayerController.asset(widget.videoPath);

  VideoPlayerValue get video => videoController.value;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  void initVideo() async {
    await videoController.initialize();
    setState(() {
      videoController.setLooping(true);
      videoController.play();
    });
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text.rich(TextSpan(
            text: widget.title,
            style: context.textTheme.bodyLarge!.copyWith(
              fontSize: 18,
              color: Palette.deepPurple,
            ),
            children: [
              const TextSpan(text: ' '),
              TextSpan(
                text: widget.boldTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          )),
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < widget.texts.length; i++) ...[
          Row(
            children: [
              Text(widget.emojis[i]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.texts[i],
                  style: const TextStyle(color: Palette.deepPurple),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        if (video.isInitialized)
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kBorderRadius),
                child: AspectRatio(
                  aspectRatio: video.aspectRatio,
                  child: VideoPlayer(videoController),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
