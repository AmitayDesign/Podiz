import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/home/components/skeletonPodcastAvatar.dart';

class PodcastAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  const PodcastAvatar({Key? key, required this.imageUrl, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => SkeletonPodcastAvatar(size: size),
      errorWidget: (context, url, error) => RoundedSquareImage(
        image: const AssetImage("assets/images/loadingImage.png"),
        size: size,
      ),
      imageBuilder: (context, imageProvider) => RoundedSquareImage(
        image: imageProvider,
        size: size,
      ),
    );
  }
}

class RoundedSquareImage extends StatelessWidget {
  final double size;
  final ImageProvider image;
  const RoundedSquareImage({Key? key, required this.size, required this.image})
      : super(key: key);

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
    );
  }
}
