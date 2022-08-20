import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:podiz/src/theme/context_theme.dart';

class StackedAvatars extends StatelessWidget {
  final List<String> imageUrls;
  final double radius;
  final double borderWidth;
  final Color? borderColor;

  StackedAvatars({
    Key? key,
    required List<String?> imageUrls,
    this.radius = 16,
    this.borderWidth = 2,
    this.borderColor,
  })  : imageUrls = imageUrls.whereNotNull().toList().cast<String>(),
        super(key: key);

  List<String> decideImages() {
    if (imageUrls.length <= 3) return imageUrls;
    return imageUrls.sublist(imageUrls.length - 4, imageUrls.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = decideImages();
    return Stack(
      children: imageUrls
          .mapIndexed(
            (i, imageUrl) => Container(
              margin: EdgeInsets.only(left: radius * i),
              padding:
                  imageUrls.length > 1 ? EdgeInsets.all(borderWidth) : null,
              decoration: BoxDecoration(
                color: borderColor ?? context.colorScheme.surface,
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
