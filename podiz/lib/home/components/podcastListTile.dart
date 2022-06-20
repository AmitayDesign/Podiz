import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/stackedImages.dart';

class PodcastListTile extends StatelessWidget {
  String category;
  PodcastListTile(this.category, {Key? key}) : super(key: key);
  List<String> podcasts = ["1", "2"];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text(category, style: podcastInsights())),
          const SizedBox(height: 10),
          ListView.builder(
            itemCount: podcasts.length,
            itemBuilder: (context, index) => buildItem(context),
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 148,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius),
          color: theme.colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  StackedImages(32),
                  const SizedBox(width: 8),
                  Text(
                    "120 Insights",
                    style: podcastInsights(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      color: theme.primaryColor,
                    ),
                    width: 68,
                    height: 68,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 250,
                    height: 68,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Here's the Renegades|Stop...",
                            style: podcastTitle(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text("The Daily Stoic",
                                    style: podcastArtist())),
                            const SizedBox(width: 12),
                            ClipOval(
                                child: Container(
                              width: 4,
                              height: 4,
                              color: const Color(0xFFD9D9D9),
                            )),
                            const SizedBox(width: 12),
                            Text("1h 13m", style: podcastArtist()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
