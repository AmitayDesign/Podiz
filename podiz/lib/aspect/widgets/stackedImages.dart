import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/objects/Podcast.dart';

class StackedImages extends StatelessWidget {
  final Podcast podcast;
  final double radius;
  const StackedImages(this.podcast, {Key? key, required this.radius})
      : super(key: key);

  List<String> decideImages(List<String> images) {
    if (images.length <= 3) return images;
    return images.sublist(images.length - 4, images.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: decideImages(podcast.commentsImg)
          .mapIndexed(
            (i, imageUrl) => Container(
              margin: EdgeInsets.only(left: radius * i),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: radius,
                backgroundImage: NetworkImage(imageUrl),
              ),
            ),
          )
          .toList(),
    );
  }
}
