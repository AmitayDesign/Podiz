import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PodcastAvatar extends StatefulWidget {
  String imageUrl;
  double size;
  PodcastAvatar({Key? key, required this.imageUrl, required this.size})
      : super(key: key);

  @override
  State<PodcastAvatar> createState() => _PodcastAvatarState();
}

class _PodcastAvatarState extends State<PodcastAvatar> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) =>
          Image.asset("assets/images/loadingImage.png"),
      imageBuilder: (context, imageProvider) => Container(
        height: widget.size,
        width: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      fit: BoxFit.cover,
    );
  }
}
