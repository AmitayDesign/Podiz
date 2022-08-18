import 'package:flutter/material.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/objects/show.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/features/podcast/presentation/avatar/podcast_avatar.dart';

class PodcastSliverHeader extends StatelessWidget {
  final Show podcast;
  final double minHeight;
  final double maxHeight;

  const PodcastSliverHeader({
    Key? key,
    required this.podcast,
    required this.minHeight,
    required this.maxHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.teal,
      title: const BackTextButton(),
      flexibleSpace: PodcastHeader(
        podcast: podcast,
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
      expandedHeight: maxHeight - MediaQuery.of(context).padding.top,
    );
  }
}

class PodcastHeader extends StatelessWidget {
  final Show podcast;
  final double minHeight;
  final double maxHeight;

  const PodcastHeader({
    Key? key,
    required this.podcast,
    required this.minHeight,
    required this.maxHeight,
  }) : super(key: key);

  double calculateRatio(BuildContext context, BoxConstraints constraints) =>
      ((constraints.maxHeight - minHeight) / (maxHeight - minHeight))
          .clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = calculateRatio(context, constraints);
        print(ratio);
        final animation = AlwaysStoppedAnimation(ratio);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16)
              .add(EdgeInsets.only(top: MediaQuery.of(context).padding.top)),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: Tween<double>(
                    begin: 0,
                    end: GradientBar.height,
                  ).evaluate(animation),
                ),
                child: PodcastAvatar(
                  imageUrl: podcast.image_url,
                  size: Tween<double>(
                    begin: 0,
                    end: 128,
                  ).evaluate(animation),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                podcast.name,
                style: context.textTheme.headlineLarge!.copyWith(
                  fontSize: Tween<double>(
                    begin: 18,
                    end: 32,
                  ).evaluate(animation),
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${podcast.followers.length} FOLLOWERS',
                style: TextStyle(
                  fontSize: Tween<double>(
                    begin: 0,
                    end: 16,
                  ).evaluate(animation),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
