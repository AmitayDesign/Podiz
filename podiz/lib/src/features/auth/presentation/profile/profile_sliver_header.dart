import 'package:flutter/material.dart';
import 'package:podiz/aspect/extensions.dart';
import 'package:podiz/aspect/widgets/appBarGradient.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/domain/user_podiz.dart';

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
      automaticallyImplyLeading: false,
      backgroundColor: Colors.teal,
      toolbarHeight: GradientBar.height,
      title: const BackTextButton(),
      flexibleSpace: Container(
        padding: EdgeInsets.only(bottom: minHeight * 0.25),
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
          padding: const EdgeInsets.symmetric(horizontal: 16)
              .add(const EdgeInsets.only(top: GradientBar.height)),
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(user: user, radius: tween(0, 48)),
              SizedBox(height: tween(0, 8)),
              Text(
                user.name,
                style: context.textTheme.titleLarge,
                maxLines: ratio == 0 ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: tween(0, 16)),
              Row(
                children: [
                  Text.rich(
                    TextSpan(
                      text: user.followers.length.toString(),
                      style: context.textTheme.titleLarge,
                      children: [
                        TextSpan(
                          text: ' Followers',
                          style: context.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text.rich(
                    TextSpan(
                      text: user.following.length.toString(),
                      style: context.textTheme.titleLarge,
                      children: [
                        TextSpan(
                          text: ' Following',
                          style: context.textTheme.bodyLarge,
                        ),
                      ],
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
}
