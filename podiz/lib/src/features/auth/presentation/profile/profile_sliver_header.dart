import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/common_widgets/app_bar_gradient.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/spotify_redirect_logo.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/context_theme.dart';

class ProfileSliverHeader extends StatelessWidget {
  final UserPodiz user;
  final double minHeight;
  final double maxHeight;

  const ProfileSliverHeader({
    Key? key,
    required this.user,
    required this.minHeight,
    required this.maxHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      actions: [SpotifyRedirectLogo(id: user.id, type: 'user')],
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      toolbarHeight: GradientBar.height,
      title: const BackTextButton(),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: extendedAppBarGradient(context.colorScheme.background),
        ),
        child: ProfileHeader(
          user: user,
          minHeight: minHeight * 1.25,
          maxHeight: maxHeight,
        ),
      ),
      collapsedHeight: minHeight * 1.25 - MediaQuery.of(context).padding.top,
      expandedHeight: maxHeight - MediaQuery.of(context).padding.top,
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final UserPodiz user;
  final double minHeight;
  final double maxHeight;

  const ProfileHeader({
    Key? key,
    required this.user,
    required this.minHeight,
    required this.maxHeight,
  }) : super(key: key);

  double calculateRatio(BoxConstraints constraints) =>
      (constraints.maxHeight - minHeight) / (maxHeight - minHeight);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = calculateRatio(constraints).clamp(0.0, 1.0);
        final animation = AlwaysStoppedAnimation(ratio);
        double tween(double begin, double end) =>
            Tween<double>(begin: begin, end: end).evaluate(animation);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16).add(
            EdgeInsets.only(
              top: GradientBar.height,
              bottom: tween(minHeight * 1 / 5, 0),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(user: user, radius: tween(0, 48)),
              SizedBox(height: tween(0, 16)),
              Row(
                children: [
                  Text(
                    user.name,
                    style: context.textTheme.titleLarge,
                    maxLines: ratio == 0 ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 4),
                  user.verified == true
                      ? const Icon(Icons.verified, size: kSmallIconSize)
                      : Container()
                ],
              ),
              SizedBox(height: tween(0, 8)),
              Row(
                children: [
                  InkWell(
                    onTap: () => _buildFollowersPopUp(
                        context, "Followers", user.followers),
                    child: Text.rich(
                      TextSpan(
                        text: user.followers.length.toString(),
                        style: context.textTheme.titleLarge!.copyWith(
                          fontSize: tween(0, 18),
                        ),
                        children: [
                          TextSpan(
                            text: ' Followers',
                            style: context.textTheme.bodyLarge!.copyWith(
                              fontSize: tween(0, 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () => _buildFollowersPopUp(
                        context, "Following", user.following),
                    child: Text.rich(
                      TextSpan(
                        text: user.following.length.toString(),
                        style: context.textTheme.titleLarge!.copyWith(
                          fontSize: tween(0, 18),
                        ),
                        children: [
                          TextSpan(
                            text: ' Following',
                            style: context.textTheme.bodyLarge!.copyWith(
                              fontSize: tween(0, 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  _buildFollowersPopUp(
      BuildContext context, String title, List<String> followers) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: followers.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(followers[index]),
                  onTap: () {
                    context.pushNamed(AppRoute.profile.name,
                        params: {'userId': followers[index]});
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
