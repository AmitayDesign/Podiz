import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/loading.dart/tabBarLabelLoading.dart';
import 'package:podiz/objects/Podcast.dart';

class TabBarLabel extends ConsumerWidget {
  final String text;
  final int number;

  const TabBarLabel(this.text, this.number, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Podcast? podcast;
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
          release_date: "",
          watching: 0);
      return _buildItem(podcast, number);
    }
    return FutureBuilder(
        future: ref.read(podcastManagerProvider).fetchPodcast(text),
        initialData: "loading",
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If we got an error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error} occurred',
                  style: const TextStyle(fontSize: 18),
                ),
              );

              // if we got our data
            } else if (snapshot.hasData) {
              final episode = snapshot.data as Podcast;
              return _buildItem(episode, number);
            }
          }
          return const TabBarLabelLoading();
        });
  }
}

Widget _buildItem(Podcast episode, int number) {
  return Tab(
    height: 32,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          children: [
            Text(number.toString()),
            episode.name != "All"
                ? Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: PodcastAvatar(imageUrl: episode.image_url, size: 20),
                  )
                : Container(),
            const SizedBox(width: 8),
            LimitedBox(
                maxWidth: 120,
                child: Text(
                  episode.name,
                  maxLines: 1,
                ))
          ],
        ),
      ),
    ),
  );
}
