import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/components/stackedImages.dart';

class DiscussionAppBar extends StatelessWidget with PreferredSizeWidget {
  const DiscussionAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Color(0xFF3E0979),
      flexibleSpace: Column(children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              StackedImages(23),
              const SizedBox(width: 8),
              Text(
                "120 Insights",
                style: discussionAppBarInsights(),
              ),
              const Spacer(),
              Text(
                "11:17 Today",
                style: discussionAppBarInsights(),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kBorderRadius),
                  color: theme.cardColor,
                ),
                width: 52,
                height: 52,
              ),
              const SizedBox(width: 8),
              Container(
                width: 250, //TODO see this
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Here's the Renegades|Stop...",
                        style: discussionAppBarTitle(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child:
                              Text("The Daily Stoic", style: discussionAppBarInsights())),
                      const SizedBox(width: 12),
                      ClipOval(
                          child: Container(
                        width: 4,
                        height: 4,
                        color: const Color(0xB2FFFFFF),
                      )),
                      const SizedBox(width: 12),
                      Text("1h 13m", style: discussionAppBarInsights()),
                    ]),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        const LinearProgressIndicator(
          backgroundColor: Color(0xFFE5CEFF),
          color: Color(0xFFD74EFF),
          minHeight: 4,
        ),
      ]),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(134);
}
