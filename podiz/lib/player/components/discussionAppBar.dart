import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/aspect/widgets/insightsRow.dart';
import 'package:podiz/aspect/widgets/stackedImages.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/Player.dart';
import 'package:podiz/player/components/pinkProgress.dart';

class DiscussionAppBar extends StatelessWidget with PreferredSizeWidget {
  Podcast? podcast;
  DiscussionAppBar(this.podcast, {Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(134);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (podcast == null) {
      return AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Palette.purpleAppBar,
          flexibleSpace: Center(
            child: Container(
              width: 20,
              height: 20,
              child: LoadingIndicator(
                indicatorType: Indicator.circleStrokeSpin,
                colors: [theme.primaryColor],
                strokeWidth: 4,
              ),
            ),
          ));
    }
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Palette.purpleAppBar,
      flexibleSpace: Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 35),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(children: [
              const Icon(
                Icons.arrow_back_ios_new,
                size: 15,
                color: Color(0xB2FFFFFF),
              ),
              const SizedBox(width: 10),
              Text(
                Locales.string(context, "back"),
                style: discussionAppBarInsights(),
              )
            ]),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: InsightsRow.quickNote(podcast!),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              PodcastAvatar(imageUrl: podcast!.image_url, size: 52),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  LimitedBox(
                    maxWidth: kScreenWidth - (16 + 52 + 8 + 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        podcast!.name,
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
                              child: Text(podcast!.show_name,
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
                          Text(timeFormatter(podcast!.duration_ms),
                              style: discussionAppBarInsights()),
                        ]),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        PinkProgress()
      ]),
    );
  }
}
