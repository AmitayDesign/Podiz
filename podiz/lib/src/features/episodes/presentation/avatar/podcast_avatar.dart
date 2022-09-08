import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:podiz/src/constants/constants.dart';

class PodcastAvatar extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onTap;
  final double size;

  const PodcastAvatar({
    Key? key,
    required this.imageUrl,
    this.onTap,
    this.size = 64,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ImageProvider image = imageUrl == null
        ? const Svg('assets/icons/placeholder.svg') as ImageProvider
        : NetworkImage(imageUrl!);

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
