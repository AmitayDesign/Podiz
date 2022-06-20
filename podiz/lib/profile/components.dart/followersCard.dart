import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/feed/components/discussionCard.dart';

class FollowersCard extends StatelessWidget {
  const FollowersCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kBorderRadius),
                  color: theme.primaryColor,
                ),
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 8),
              Container(
                width: 250,
                height: 32,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Here's the Renegades|Stop...",
                        style: discussionCardProfile(),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text("The Daily Stoic", style: discussionAppBarInsights())),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DiscussionCard(),
      ],
    );
  }
}
