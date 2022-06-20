import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class TabBarLabel extends StatelessWidget {
  String text;
  int number;

  TabBarLabel(this.text, this.number, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tab(
      height: 32,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Text(number.toString()),
              text != "All"
                  ? const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: CircleAvatar(
                        backgroundColor: Color(0xFFD74EFF),
                        radius: 10,
                      ),
                    )
                  : Container(),
              const SizedBox(width: 8),
              Text(text)
            ],
          ),
        ),
      ),
    );
  }
}

// class CircleTabIndicator extends Decoration {
//   final Color color;
//   double radius;

//   CircleTabIndicator(this.color, this.radius);

//   @override
//   BoxPainter createBoxPainter([VoidCallback? onChanged]) {
//     return _CirclePainter(color: color, radius: radius);
//   }
// }

// class _CirclePainter extends BoxPainter {
//   final Color color;
//   double radius;

//   _CirclePainter({required this.color, required this.radius});
//   @override
//   void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
//     Paint _paint = Paint();
//     _paint.color = color;
//     _paint.isAntiAlias = true;

//     canvas.drawCircle(offset, radius, _paint);
//   }
// }
