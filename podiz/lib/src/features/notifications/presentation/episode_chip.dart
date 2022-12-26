import 'package:flutter/material.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/podcast_avatar.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/utils/string_zwsp.dart';

class EpisodeChip extends StatelessWidget {
  static const height = 32.0;
  final Episode? episode;
  final int counter;
  final Color? color;
  final VoidCallback? onTap;

  const EpisodeChip(
    this.episode, {
    Key? key,
    required this.counter,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const StadiumBorder(),
      color: color ?? context.colorScheme.surface,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                counter.toString(),
                style: context.textTheme.titleSmall,
              ),
              if (episode != null) ...[
                const SizedBox(width: 8),
                PodcastAvatar(
                  imageUrl: episode!.imageUrl,
                  size: kSmallIconSize,
                ),
              ],
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 128),
                child: Text(
                  episode?.name.useCorrectEllipsis() ?? 'All',
                  style: context.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
