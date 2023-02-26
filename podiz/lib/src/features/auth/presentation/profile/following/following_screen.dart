import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/app_bar_gradient.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/features/auth/presentation/profile/following/following_list.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';

class FollowingScreen extends ConsumerWidget {
  FollowingScreen(this.user, {Key? key, this.index = 0}) : super(key: key);

  UserPodiz user;
  int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print(user.followers);
    print(user.following);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          toolbarHeight: 64,
          title: const BackTextButton(),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: extendedAppBarGradient(context.colorScheme.background),
            ),
            height: (64 * 1.25) + MediaQuery.of(context).padding.top,
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.label,
            unselectedLabelColor: Palette.grey600,
            labelStyle: context.textTheme.titleLarge,
            tabs: [
              Tab(
                text: "Following ${user.following.length}",
                height: 30,
              ),
              Tab(
                text: "Followers ${user.followers.length}",
                height: 30,
              )
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TabBarView(children: [
            FollowingList(user.following),
            FollowingList(user.followers),
          ]),
        ),
      ),
    );
  }
}
