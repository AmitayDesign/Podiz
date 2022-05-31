import 'package:podiz/aspect/constants.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:podiz/home/components/HomeAppBar.dart';
import 'package:podiz/home/components/player.dart';
import 'package:podiz/home/components/podcastListTile.dart';
import 'package:podiz/home/components/podcastListTileQuickNote.dart';
import 'package:podiz/home/homePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedPage extends ConsumerStatefulWidget with HomePageMixin {
  @override
  final String label = 'Home';
  @override
  final Widget icon = const Icon(Icons.home);
  @override
  final Widget activeIcon = const Icon(Icons.home, color: Color(0xFF6310BF));

  FeedPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

bool player = true;

class _FeedPageState extends ConsumerState<FeedPage> {
  List<String> categories = [
    "Last Listened",
    "My Casts",
    "Hot & Live",
    "One More"
  ]; //TODO change to locales
  List<int> categories_post = [1, 2, 2, 2];
  @override
  void initState() {
    _controller.addListener(handleAppBar);
    super.initState();
  }

  handleAppBar() {
    int size = 0;

    if (_controller.position.pixels == 0) {
      setState(() {
        title = "";
      });
      return;
    }

    for (int i = 0; i < categories.length; i++) {
      size += 16;
      if (_controller.position.pixels >= size &&
          _controller.position.pixels <=
              size + 10 + (8 + 8 + 148) * categories_post[i] + 20) {
        setState(() {
          title = categories[i];
        });
        break;
      }
      size += 10 + (8 + 8 + 148) * categories_post[i] + 20;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final _controller = ScrollController();
  String title = "";

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            HomeAppBar(title),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  controller: _controller,
                  itemCount: categories.length,
                  itemBuilder: (context, index) => index == 0
                      ? PodcastListTileQuickNote("Last Listened")
                      : PodcastListTile(categories[index]),
                ),
              ),
            ),
            player ? const SizedBox(height: 100) : Container()
          ],
        ),
        player ? Player() : Container()
      ],
    );
  }
}
