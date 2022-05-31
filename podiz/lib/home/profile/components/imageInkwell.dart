import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class ImageInkwell extends StatelessWidget {
  const ImageInkwell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      child: InkWell(
        onTap: () => print("dengue"),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt),
            SizedBox(width: 10,),
            Text(
              Locales.string(context, "image"),
              style: theme.textTheme.bodyText1,
            )
          ],
        ),
      ),
    );
  }
}
