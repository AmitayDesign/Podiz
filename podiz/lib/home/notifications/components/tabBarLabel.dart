import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/objects/Podcast.dart';

class TabBarLabel extends ConsumerWidget {
  String text;
  int number;

  TabBarLabel(this.text, this.number, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    Podcast podcast;
    if (text == "All") {
      podcast = Podcast("",
          name: "All",
          description: "",
          duration_ms: 0,
          show_name: "",
          show_uri: "",
          image_url: "",
          comments: 0,
          commentsImg: [],
          release_date: "");
    } else {
      podcast = ref
          .read(podcastManagerProvider)
          .getPodcastById(text)
          .searchResultToPodcast();
    }
    return Tab(
      height: 32,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Text(number.toString()),
              text != "All"
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child:
                          PodcastAvatar(imageUrl: podcast.image_url, size: 20),
                    )
                  : Container(),
              const SizedBox(width: 8),
              LimitedBox(
                  maxWidth: 200,
                  child: Text(
                    podcast.name,
                    maxLines: 1,
                  ))
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
