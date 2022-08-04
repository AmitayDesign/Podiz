import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/authentication/authManager.dart';
import 'package:podiz/home/components/HomeAppBar.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/loading.dart/episodeLoading.dart';
import 'package:podiz/loading.dart/snackBarLoading.dart';
import 'package:podiz/player/PlayerManager.dart';
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
    // numberCast = widget.user.favPodcasts.length;

    // int lastListenedSize = lastListened ? 196 : 0;
    // int myCastsSize = numberCast > 0
    //     ? numberCast * (8 + 8 + 148) + 20 + 10 + lastListenedSize
    //     : 0;
    // double position = _controller.position.pixels;

    // if (lastListened && position < lastListenedSize) {
    //   if (title != "lastListened") {
    //     setState(() => title = "lastlistened");
    //   }
    // } else if (numberCast > 0 &&
    //     position > lastListenedSize &&
    //     position < myCastsSize) {
    //   if (title != "mycasts") {
    //     setState(() => title = "mycasts");
    //   }
    // } else {
    //   if (title != "hotlive") {
    //     setState(() => title = "hotlive");
    //   }
    // }
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

  var queryFeed = FirebaseFirestore.instance
      .collection("podcasts")
      .orderBy("release_date", descending: true)
      .withConverter(
          fromFirestore: (snapshot, _) => Podcast.fromJson(snapshot.data()!),
          toFirestore: (user, _) {
            return {};
          });

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
    final lastListenedEpisode = ref.watch(lastListenedEpisodeFutureProvider);
    return GestureDetector(
        onTap: () {
          _focusNode.unfocus();
          setState(() {
            visible = false;
          });
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 104.0, left: 16, right: 16), //TODO size of appbar
              child: CustomScrollView(controller: _controller, slivers: [
                widget.user.lastListened == ""
                    ? Container()
                    : SliverToBoxAdapter(
                        child: lastListenedEpisode.when(
                        loading: () => const EpisodeLoading(),
                        error: (_, stackTree) => SplashScreen.error(),
                        data: (ep) => PodcastListTileQuickNote(ep,
                            quickNote: quickNote(ep)),
                      )),
                if (widget.user.favPodcasts.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("My Cast", style: podcastInsights())),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  //TODO List
                ],
                SliverToBoxAdapter(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Hot & Live", style: podcastInsights())),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                FirestoreQueryBuilder<Podcast>(
                  query: queryFeed,
                  builder: (context, snapshot, _) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (snapshot.hasMore &&
                              index + 1 == snapshot.docs.length) {
                            snapshot.fetchMore();
                          }

                          Podcast episode =
                              snapshot.docs[index].data() as Podcast;
                          episode.uid = snapshot.docs[index].id;
                          return PodcastListTile(episode);
                        },
                        childCount: snapshot.docs.length,
                      ),
                    );
                  },
                ),
              ]),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: HomeAppBar(title),
            ),
            if (visible) ...[
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: commentView(widget.user.lastListened),
              )
            ] else ...[
              Container(),
            ]
          ],
        ));

    //       Column(
    //         children: [
    //           HomeAppBar(title),
    //           Expanded(
    //             child: Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 16.0),
    //               child: SingleChildScrollView(
    //                 child: Column(children: [
    //                   widget.user.lastListened == ""
    //                       ? Container()
    //                       : lastListenedEpisode.when(
    //                           loading: () => const EpisodeLoading(),
    //                           error: (_, stackTree) => SplashScreen.error(),
    //                           data: (ep) => PodcastListTileQuickNote(ep,
    //                               quickNote: quickNote(ep))),
    //                   // if (widget.user.favPodcasts.isNotEmpty) ...[ TODO deal with this!!!
    //                   //   Align(
    //                   //       alignment: Alignment.centerLeft,
    //                   //       child: Text("My Cast", style: podcastInsights())),
    //                   //   const SizedBox(height: 10),
    //                   //   Container(
    //                   //     child: FirestoreListView(
    //                   //         primary: false,
    //                   //         // shrinkWrap: true,
    //                   //         query: queryFeed, //TODo change this
    //                   //         itemBuilder: (context, snapshot) {
    //                   //           Podcast episode = snapshot.data() as Podcast;
    //                   //           return PodcastListTile(episode);
    //                   //         }),
    //                   //   ),
    //                   // ],
    //                   Align(
    //                       alignment: Alignment.centerLeft,
    //                       child: Text("Hot & Live", style: podcastInsights())),
    //                   const SizedBox(height: 10),
    //                   FirestoreQueryBuilder(
    //                       pageSize: 5,
    //                       query: queryFeed,
    //                       builder: (context, snapshot, _) {
    //                         if (snapshot.isFetching) {
    //                           return const EpisodeLoading();
    //                         }
    //                         if (snapshot.hasError) {
    //                           return Text(
    //                               'Something went wrong! ${snapshot.error}');
    //                         }
    //                         return ListView.builder(
    //                             shrinkWrap: true,
    //                             itemCount: snapshot.docs.length,
    //                             itemBuilder: (context, index) {
    //                               if (snapshot.hasMore &&
    //                                   index + 1 == snapshot.docs.length) {
    //                                 snapshot.fetchMore();
    //                               }
    //                               Podcast episode =
    //                                   snapshot.docs[index].data() as Podcast;
    //                               episode.uid = snapshot.docs[index].id;
    //                               return PodcastListTile(episode);
    //                             });
    //                       }),
    //                 ]),
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //       if (visible) ...[
    //         Positioned(
    //           bottom: 0,
    //           left: 0,
    //           right: 0,
    //           child: commentView(widget.user.lastListened),
    //         )
    //       ] else ...[
    //         Container(),
    //       ]
    //     ]),
    //   );
  }

  Widget commentView(String episodeUid) {
    return FutureBuilder(
        future:
            ref.read(podcastManagerProvider).getPodcastFromFirebase(episodeUid),
        initialData: "loading",
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If we got an error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error} occurred',
                  style: TextStyle(fontSize: 18),
                ),
              );

              // if we got our data
            } else if (snapshot.hasData) {
              final episode = snapshot.data as Podcast;

              return Container(
                height: 127,
                decoration: const BoxDecoration(
                  color: Color(0xFF4E4E4E),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleProfile(
                            user: ref.read(authManagerProvider).userBloc!,
                            size: 15.5,
                          ),
                          const SizedBox(width: 8),
                          LimitedBox(
                            maxWidth:
                                kScreenWidth - (14 + 31 + 8 + 31 + 8 + 14),
                            maxHeight: 31,
                            child: TextField(
                              // key: _key,
                              maxLines: 5,
                              keyboardType: TextInputType.multiline,
                              focusNode: _focusNode,
                              controller: _controllerText,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF262626),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                hintStyle: discussionSnackCommentHint(),
                                hintText: "Share your insight...",
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              ref.read(authManagerProvider).doComment(
                                  _controllerText.text,
                                  episode.uid!,
                                  episode.duration_ms);

                              setState(() {
                                visible = false;
                              });
                              _focusNode.unfocus();
                              _controllerText.clear();
                            },
                            child: const Icon(
                              Icons.send,
                              size: 31,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            "${episode.watching} listening right now",
                            style: discussionAppBarInsights(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
          }
          return const SnackBarLoading();
        });
  }

  Widget quickNote(Podcast ep) {
    return Container(
      height: 31,
      decoration: BoxDecoration(
        color: Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(
              Icons.edit,
              size: 16,
              color: Color(0xFF9E9E9E),
            ),
            const SizedBox(width: 10),
            Text(Locales.string(context, "quicknote"),
                style: podcastArtistQuickNote()),
          ]),
          onTap: () {
            setState(() {
              visible = true;
              _focusNode.requestFocus();
            });
          }),
    );
  }
}
