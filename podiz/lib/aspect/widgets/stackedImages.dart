import 'package:flutter/material.dart';
import 'package:image_stack/image_stack.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/objects/Podcast.dart';

class StackedImages extends StatelessWidget {
  Podcast podcast;
  double size;

  StackedImages(this.podcast, {Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int dif = size ~/ 2;
    final shift = size - dif;
    List<String> images = decideList(podcast.commentsImg);
    List<Widget> widgets = images
        .asMap()
        .map((index, img) {
          final image = Container(
            width: size,
            height: size,
            child: buildimages(context, img, size),
            margin: EdgeInsets.only(left: shift * index),
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
    final theme = Theme.of(context);
    return ClipOval(
      child: Container(
        color: const Color(0xFF262626),
        padding: EdgeInsets.all(1),
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