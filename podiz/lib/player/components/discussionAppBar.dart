import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/insightsRow.dart';
import 'package:podiz/aspect/widgets/stackedImages.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/objects/Podcast.dart';

class DiscussionAppBar extends StatefulWidget with PreferredSizeWidget {
  Podcast podcast;
  DiscussionAppBar(this.podcast, {Key? key}) : super(key: key);

  @override
  State<DiscussionAppBar> createState() => _DiscussionAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(134);
}

class _DiscussionAppBarState extends State<DiscussionAppBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final podcast = widget.podcast;
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Color(0xFF3E0979),
      flexibleSpace: Column(children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: InsightsRow.quickNote(podcast),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              PodcastAvatar(imageUrl: podcast.image_url, size: 52),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  LimitedBox(
                    maxWidth: kScreenWidth - (16 + 52 + 8 + 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        podcast.name,
                        style: discussionAppBarTitle(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LimitedBox(
                    maxWidth: kScreenWidth - (16 + 52 + 8 + 16),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: LimitedBox(
                              maxWidth: kScreenWidth -
                                  (16 + 52 + 8 + 12 + 4 + 12 + 62 + 16),
                              child: Text(podcast.show_name,
                                  style: discussionAppBarInsights()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ClipOval(
                              child: Container(
                            width: 4,
                            height: 4,
                            color: const Color(0xB2FFFFFF),
                          )),
                          const SizedBox(width: 12),
                          Text(timeFormatter(podcast.duration_ms),
                              style: discussionAppBarInsights()),
                        ]),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        const LinearProgressIndicator(
          backgroundColor: Color(0xFFE5CEFF),
          color: Color(0xFFD74EFF),
          minHeight: 4,
        ),
      ]),
    );
  }
}
