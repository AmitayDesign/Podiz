import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/loading.dart/tabBarLabelLoading.dart';
import 'package:podiz/src/features/episodes/data/episode_repository.dart';
import 'package:podiz/src/features/episodes/domain/episode.dart';
import 'package:podiz/src/features/podcast/presentation/avatar/podcast_avatar.dart';

class TabBarLabel extends ConsumerWidget {
  final String text;
  final int number;

  const TabBarLabel(this.text, this.number, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (text == "All") {
      final episode = Episode(
        id: "",
        name: "All",
        description: "",
        duration: 0,
        showName: "",
        showId: "",
        imageUrl: "",
        commentsCount: 0,
        commentImageUrls: [],
        releaseDateString: "",
        userIdsWatching: [],
      );
      return _buildItem(episode, number);
    }
    final episodeValue = ref.watch(episodeFutureProvider(text));
    return episodeValue.when(
      error: (e, _) => Center(
        child: Text(
          '$e occurred',
          style: const TextStyle(fontSize: 18),
        ),
      ),
      loading: () => const TabBarLabelLoading(),
      data: (episode) => _buildItem(episode, number),
    );
  }
}

Widget _buildItem(Episode episode, int number) {
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
                    child: PodcastAvatar(imageUrl: episode.imageUrl, size: 20),
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
