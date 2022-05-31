import 'package:flutter/material.dart';
import 'package:image_stack/image_stack.dart';

class StackedImages extends StatelessWidget {
  StackedImages(this.size, {Key? key}) : super(key: key);
  double size;
  List<String> images = ["brandIcon.png", "brandIcon.png", "brandIcon.png"];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int dif = size ~/ 2;
    final shift = size - dif;
    List<Widget> widgets = images
        .asMap()
        .map((index, img) {
          final image = Container(
            width: size,
            height: size,
            child: buildimages(context, img),
            margin: EdgeInsets.only(left: shift * index),
          );
          return MapEntry(index, image);
        })
        .values
        .toList();

    return Stack(
      children: widgets,
    );
  }

  // Widget buildStackedIamges() {
  //   return StackedWidgets(widgets: widgets, size: size);
  // }

  Widget buildimages(BuildContext context, String path) {
    final theme = Theme.of(context);
    //TODO change this
    return ClipOval(
      child: Container(
        color: const Color(0xFF262626),
        padding: EdgeInsets.all(1),
        child: ClipOval(
          child: Image.asset(
            "assets/images/$path",
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
