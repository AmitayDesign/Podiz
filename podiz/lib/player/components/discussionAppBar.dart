import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/formatters.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/widgets/insightsRow.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/player/components/pinkProgress.dart';
import 'package:podiz/profile/components.dart/backAppBar.dart';

class DiscussionAppBar extends ConsumerWidget with PreferredSizeWidget {
  final Podcast? podcast;
  DiscussionAppBar(this.podcast, {Key? key}) : super(key: key);

  static const height = 64.0;
  static const flexibleHeight = 156.0;

  @override
  Size get preferredSize =>
      Size.fromHeight(podcast == null ? height : flexibleHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      toolbarHeight: height,
      automaticallyImplyLeading: false,
      backgroundColor: Palette.purpleAppBar,
      title: const BackAppBarButton(),
      flexibleSpace: podcast == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: height),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InsightsRow.quickNote(podcast!),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        PodcastAvatar(imageUrl: podcast!.image_url, size: 52),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                podcast!.name + podcast!.name,
                                style: context.textTheme.titleMedium!
                                    .copyWith(color: Colors.grey.shade50),
                                maxLines: 1,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        podcast!.show_name,
                                        style: context.textTheme.bodyMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ClipOval(
                                      child: Container(
                                        width: 4,
                                        height: 4,
                                        color: const Color(0xB2FFFFFF),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      timeFormatter(podcast!.duration_ms),
                                      style: context.textTheme.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ]),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  PinkProgress(podcast!.duration_ms),
                ],
              ),
            ),
    );
  }
}
