import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/episodes/presentation/avatar/skeleton_podcast_avatar.dart';
import 'package:podiz/src/routing/app_router.dart';

class PodcastAvatar extends StatelessWidget {
  final String? episodeId;
  final String? podcastId;
  final String imageUrl;
  final double size;

  const PodcastAvatar({
    Key? key,
    required this.imageUrl,
    this.episodeId,
    this.podcastId,
    this.size = 64,
  })  : assert(episodeId == null || podcastId == null),
        super(key: key);

  bool get isEpisode => episodeId != null;
  bool get isPodcast => podcastId != null;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: size,
      width: size,
      placeholder: (context, url) => SkeletonPodcastAvatar(size: size),
      errorWidget: (context, url, error) => RoundedSquareImage(
        image: const AssetImage("assets/images/loadingImage.png"),
        size: size,
      ),
      imageBuilder: (context, imageProvider) => RoundedSquareImage(
        image: imageProvider,
        size: size,
        onTap: isEpisode
            ? () => context.pushNamed(
                  AppRoute.discussion.name,
                  params: {'episodeId': episodeId!},
                )
            : isPodcast
                ? () => context.pushNamed(
                      AppRoute.podcast.name,
                      params: {'podcastId': podcastId!},
                    )
                : null,
      ),
    );
  }
}

class RoundedSquareImage extends StatelessWidget {
  final ImageProvider image;
  final double size;
  final VoidCallback? onTap;

  const RoundedSquareImage({
    Key? key,
    required this.image,
    required this.size,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kBorderRadius),
        image: DecorationImage(
          image: image,
          fit: BoxFit.cover,
        ),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(kBorderRadius),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: InkWell(onTap: onTap),
      ),
    );
  }
}
