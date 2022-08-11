import 'package:flutter/material.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/objects/Podcast.dart';

class StackedImages extends StatelessWidget {
  final Podcast podcast;
  final double size;

  const StackedImages(this.podcast, {Key? key, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int dif = size ~/ 2;
    final shift = size - dif;
    List<String> images = decideList(podcast.commentsImg);
    List<Widget> widgets = images
        .asMap()
        .map((index, img) {
          final image = Container(
            width: size,
            height: size,
            margin: EdgeInsets.only(left: shift * index),
            child: buildimages(context, img, size),
          );
          return MapEntry(index, image);
        })
        .values
        .toList();

    return widgets.isEmpty
        ? Container()
        : Stack(
            children: widgets,
          );
  }

  Widget buildimages(BuildContext context, String path, double size) {
    return ClipOval(
      child: Container(
        color: const Color(0xFF262626),
        padding: const EdgeInsets.all(1),
        child: ClipOval(
            child: PodcastAvatar(
          imageUrl: path,
          size: size,
        )),
      ),
    );
  }

  decideList(List<String> images) {
    if (images.length <= 3) {
      return images;
    } else {
      return images.sublist(images.length - 3, images.length - 1);
    }
  }
}
