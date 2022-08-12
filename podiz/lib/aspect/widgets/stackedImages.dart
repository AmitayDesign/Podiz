import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/objects/Podcast.dart';

class StackedImages extends StatelessWidget {
  final Podcast podcast;
  final double radius;
  const StackedImages(this.podcast, {Key? key, required this.radius})
      : super(key: key);

  final borderWidth = 2.0;

  List<String> decideImages(List<String> images) {
    if (images.length <= 3) return images;
    return images.sublist(images.length - 4, images.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = decideImages(podcast.commentsImg);
    return Stack(
      children: imageUrls
          .mapIndexed(
            (i, imageUrl) => Container(
              margin: EdgeInsets.only(left: radius * i),
              padding:
                  imageUrls.length > 1 ? EdgeInsets.all(borderWidth) : null,
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: imageUrls.length > 1 ? radius - borderWidth : radius,
                backgroundImage: NetworkImage(imageUrl),
              ),
            ),
          )
          .toList(),
    );
  }
}
