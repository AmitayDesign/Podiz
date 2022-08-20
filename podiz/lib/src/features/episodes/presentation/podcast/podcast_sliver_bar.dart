import 'package:flutter/material.dart';
import 'package:podiz/src/common_widgets/app_bar_gradient.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/features/episodes/domain/podcast.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/theme/context_theme.dart';

class PodcastSliverHeader extends StatelessWidget {
  final Podcast podcast;
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
      backgroundColor: Colors.transparent,
      toolbarHeight: GradientBar.height,
      title: const BackTextButton(),
      flexibleSpace: Container(
        padding: EdgeInsets.only(bottom: minHeight * 0.25),
        decoration: BoxDecoration(
          gradient: extendedAppBarGradient(context.colorScheme.background),
        ),
        child: PodcastHeader(
          podcast: podcast,
          minHeight: minHeight * 1.25,
          maxHeight: maxHeight,
        ),
      ),
      collapsedHeight: minHeight * 1.25 - MediaQuery.of(context).padding.top,
      expandedHeight: maxHeight - MediaQuery.of(context).padding.top,
    );
  }
}

class PodcastHeader extends StatelessWidget {
  final Podcast podcast;
  final double minHeight;
  final double maxHeight;

  const PodcastHeader({
    Key? key,
    required this.podcast,
    required this.minHeight,
    required this.maxHeight,
  }) : super(key: key);

  double calculateRatio(BoxConstraints constraints) =>
      (constraints.maxHeight - minHeight) / (maxHeight - minHeight);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = calculateRatio(constraints).clamp(0.0, 1.0);
        final animation = AlwaysStoppedAnimation(ratio);
        double tween(double begin, double end) =>
            Tween<double>(begin: begin, end: end).evaluate(animation);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16)
              .add(const EdgeInsets.only(top: GradientBar.height)),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PodcastAvatar(
                imageUrl: podcast.imageUrl,
                size: tween(0, 128),
              ),
              SizedBox(height: tween(0, 16)),
              Text(
                podcast.name,
                style: context.textTheme.headlineLarge!.copyWith(
                  fontSize: tween(18, 32),
                ),
                maxLines: ratio == 0 ? 1 : 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: tween(0, 8)),
              Text(
                '${podcast.followers.length} Followers',
                style: TextStyle(fontSize: tween(0, 16)),
              ),
            ],
          ),
        );
      },
    );
  }
}
