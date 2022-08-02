import 'package:flutter_locales/flutter_locales.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:podiz/home/components/HomeAppBar.dart';
import 'package:podiz/player/playerWidget.dart';
import 'package:podiz/home/components/podcastListTile.dart';
import 'package:podiz/home/feed/components/podcastListTileQuickNote.dart';
import 'package:podiz/home/homePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/providers.dart';
import 'package:podiz/splashScreen.dart';

class FeedPage extends ConsumerStatefulWidget with HomePageMixin {
  @override
  final String label = 'Home';
  @override
  final Widget icon = const Icon(Icons.home);
  @override
  final Widget activeIcon = const Icon(Icons.home, color: Color(0xFFD74EFF));

  bool isPlaying;
  UserPodiz user;

  FeedPage(this.isPlaying, {Key? key, required this.user}) : super(key: key);

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final _controller = ScrollController();

  late TextEditingController _controllerText;
  late FocusNode _focusNode;

  String title = "";
  int categories = 1;
  int numberCast = 0;
  bool lastListened = false;
  List<Podcast> hotlivePodcasts = [];
  List<Podcast> mycastPodcasts = [];

  @override
  void initState() {
    if (widget.user.lastListened != "") {
      title = "lastlistened";
      lastListened = true;
    } else if (widget.user.favPodcasts.isNotEmpty) {
      title = "mycasts";
    } else if (!lastListened && numberCast == 0) {
      title = "hotlive";
    }
    PodcastManager podcastManager = ref.read(podcastManagerProvider);
    hotlivePodcasts = podcastManager.getHotLive();
    mycastPodcasts = podcastManager.getMyCast();
    _controller.addListener(handleAppBar);
    _focusNode = FocusNode();
    _controllerText = TextEditingController();
    super.initState();
  }

  handleAppBar() {
    numberCast = widget.user.favPodcasts.length;

    int lastListenedSize = lastListened ? 196 : 0;
    int myCastsSize = numberCast > 0
        ? numberCast * (8 + 8 + 148) + 20 + 10 + lastListenedSize
        : 0;
    double position = _controller.position.pixels;

    if (lastListened && position < lastListenedSize) {
      if (title != "lastListened") {
        setState(() => title = "lastlistened");
      }
    } else if (numberCast > 0 &&
        position > lastListenedSize &&
        position < myCastsSize) {
      if (title != "mycasts") {
        setState(() => title = "mycasts");
      }
    } else {
      if (title != "hotlive") {
        setState(() => title = "hotlive");
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  bool visible = false;
  Function onTap() {
    return () {
      setState(() {
        visible = true;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = [
      Locales.string(context, "lastlistened"),
      Locales.string(context, "mycasts"),
      Locales.string(context, "hotlive"),
    ];

    PodcastManager podcastManager = ref.read(podcastManagerProvider);

    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
        setState(() {
          visible = false;
        });
      },
      child: Stack(
        children:[ Column(
          children: [
            HomeAppBar(title),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                    controller: _controller,
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return widget.user.lastListened != ""
                              ? PodcastListTileQuickNote(podcastManager
                                  .getPodcastById(widget.user.lastListened))
                              : Container();
                        case 1:
                          return widget.user.favPodcasts.isNotEmpty
                              ? PodcastListTile(categories[1], mycastPodcasts)
                              : Container();
                        case 2:
                          return PodcastListTile(categories[2], hotlivePodcasts);
                        case 3:
                          return SizedBox(height: widget.isPlaying ? 197 : 93);
                        default:
                          return Container();
                      }
                    }),
              ),
            ),
          ],
        ),
      
      ]),
    );
  }

  Widget commentView() {
    return Container()
    ;
  }
}
