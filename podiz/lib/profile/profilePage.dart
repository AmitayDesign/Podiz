import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/palette.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/authentication/AuthManager.dart';
import 'package:podiz/home/components/circleProfile.dart';
import 'package:podiz/home/components/podcastAvatar.dart';
import 'package:podiz/home/components/replyView.dart';
import 'package:podiz/home/feed/components/buttonPlay.dart';
import 'package:podiz/home/feed/components/cardButton.dart';
import 'package:podiz/home/search/managers/podcastManager.dart';
import 'package:podiz/home/search/managers/showManager.dart';
import 'package:podiz/loading.dart/notificationLoading.dart';
import 'package:podiz/loading.dart/shimmerContainer.dart';
import 'package:podiz/objects/Comment.dart';
import 'package:podiz/objects/Podcast.dart';
import 'package:podiz/objects/Podcaster.dart';
import 'package:podiz/objects/user/User.dart';
import 'package:podiz/profile/components.dart/backAppBar.dart';
import 'package:podiz/profile/components.dart/followPeopleButton.dart';
import 'package:podiz/profile/userManager.dart';

class ProfilePage extends ConsumerStatefulWidget {
  static const route = '/profile';
  UserPodiz user;
  ProfilePage(this.user, {Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  bool visible = false;
  Comment? commentToReply;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ShowManager showManager = ref.read(showManagerProvider);
    AuthManager authManager = ref.read(authManagerProvider);

    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
        setState(() {
          visible = false;
        });
      },
      child: Scaffold(
        appBar: BackAppBar(),
        floatingActionButton: authManager.userBloc!.uid != widget.user.uid
            ? FollowPeopleButton(widget.user)
            : Container(),
        body: Stack(children: [
          Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(widget.user.image_url),
                      radius: 50,
                    ),
                  ),

                  const SizedBox(height: 12),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.user.name,
                        style: followerName(),
                      )),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(widget.user.followers.length.toString(),
                          style: followersNumber()),
                      const SizedBox(width: 4),
                      Text("Followers", style: followersText()),
                      const SizedBox(width: 16),
                      Text(widget.user.following.length.toString(),
                          style: followersNumber()),
                      const SizedBox(width: 4),
                      Text("Following", style: followersText()),
                    ],
                  ),

                  widget.user.favPodcasts.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: SizedBox(
                            width: kScreenWidth,
                            child: Text(
                              "${widget.user.name.split(" ")[0]}'s Favorite Podcasts",
                              textAlign: TextAlign.left,
                              style: followersFavorite(),
                            ),
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 8),
                  widget.user.favPodcasts.isNotEmpty
                      ? SizedBox(
                          height: 68,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: widget.user.favPodcasts.map((show) {
                              return _buildFavouriteItem(show);
                            }).toList(),
                          ),
                        )
                      : Container() //change this
                ],
              ),
            ),
            const SizedBox(height: 54),
            widget.user.comments.isNotEmpty
                ? Expanded(
                    child: ListView(
                      children: widget.user.comments.reversed
                          .map(_buildItem)
                          .toList(),
                    ),
                  )
                : Container() //change this
          ]),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: visible ? replyView() : Container(),
          )
        ]),
      ),
    );
  }

  Widget _buildFavouriteItem(String showUid) {
    return FutureBuilder(
        future: ref.read(showManagerProvider).getShowFromFirebase(showUid),
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
              final show = snapshot.data as Podcaster;
              return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: PodcastAvatar(imageUrl: show.image_url, size: 68));
            }
          }
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ShimmerContainer(width: 68, height: 68, borderRadius: 20),
          );
        });
  }

  Widget _buildItem(Comment c) {
    final theme = Theme.of(context);
    return FutureBuilder(
        future: ref
            .read(podcastManagerProvider)
            .getPodcastFromFirebase(c.episodeUid),
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
              episode.uid = c.episodeUid;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        PodcastAvatar(imageUrl: episode.image_url, size: 32),
                        const SizedBox(width: 8),
                        Container(
                          width: kScreenWidth - (16 + 32 + 8 + 16),
                          height: 40,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  episode.name,
                                  style: discussionCardProfile(),
                                ),
                              ),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(episode.show_name,
                                      style: discussionAppBarInsights())),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    color: theme.colorScheme.surface,
                    width: kScreenWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14.0, vertical: 9),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleProfile(user: widget.user, size: 20),
                              const SizedBox(
                                width: 8,
                              ),
                              SizedBox(
                                width: 200,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        widget.user.name,
                                        style: discussionCardProfile(),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            "${widget.user.followers.length} followers",
                                            style: discussionCardFollowers())),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              ButtonPlay(episode, c.time),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: kScreenWidth - 32,
                            child: Text(
                              c.comment,
                              style: discussionCardComment(),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const SizedBox(height: 12),
                          c.lvl == 4
                              ? Container()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          visible = true;
                                          commentToReply = c;
                                        });
                                        _focusNode.requestFocus();
                                      },
                                      child: Container(
                                          width: kScreenWidth -
                                              (16 + 20 + 16 + 16),
                                          height: 33,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Palette.grey900,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Comment on ${widget.user.name} insight...",
                                                style:
                                                    discussionSnackCommentHint(),
                                              ),
                                            ),
                                          )),
                                    ),
                                    const Spacer(),
                                    CardButton(
                                      const Icon(
                                        Icons.share,
                                        color: Color(0xFF9E9E9E),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }
          }
          return const NotificationLoading();
        });
  }

  Widget replyView() {
    return FutureBuilder(
      future:
          ref.read(userManagerProvider).getUserFromUid(commentToReply!.userUid),
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
            final user = snapshot.data as UserPodiz;
            return Container(
              width: kScreenWidth,
              decoration: const BoxDecoration(
                color: Color(0xFF4E4E4E),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Replying to...",
                        style: podcastInsightsQuickNote(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleProfile(user: user, size: 20),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            Text(
                              user.name,
                              style: discussionCardProfile(),
                            ),
                            Text("${user.followers.length} Followers",
                                style: discussionCardFollowers()),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(commentToReply!.comment,
                            style: discussionCardComment())),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleProfile(user: user, size: 15.5),
                        const SizedBox(width: 8),
                        LimitedBox(
                          maxWidth: kScreenWidth - (14 + 31 + 8 + 31 + 8 + 14),
                          maxHeight: 31,
                          child: TextField(
                            // key: _key,
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            focusNode: _focusNode,
                            controller: _controller,
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
                              hintText: "Comment on ${user.name} insight...",
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            ref
                                .read(authManagerProvider)
                                .doReply(commentToReply!, _controller.text);
                            setState(() {
                              visible = false;
                              commentToReply = null;
                              _controller.clear();
                            });
                          },
                          child: Container(
                            height: 31,
                            width: 31,
                            decoration: BoxDecoration(
                              color: Palette.darkPurple,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.send,
                              size: 11,
                              color: Palette.pureWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            );
          }
        }
        return Container(
          width: kScreenWidth,
          height: 50,
          decoration: const BoxDecoration(
            color: Color(0xFF4E4E4E),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
