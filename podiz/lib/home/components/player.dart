import 'package:flutter/material.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:podiz/aspect/constants.dart';
import 'package:podiz/aspect/theme/theme.dart';
import 'package:podiz/home/feed/screens/discussionPage.dart';

class Player extends StatefulWidget {
  Player({Key? key}) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.pushNamed(context, DiscussionPage.route),
      child: Column(
        children: [
          LinearProgressIndicator(
            backgroundColor: const Color(0xFFE5CEFF),
            color: const Color(0xFFD74EFF),
            minHeight: 4,
          ),
          Container(
            height: 100,
            color: const Color(0xFF3E0979),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(kBorderRadius),
                        color: theme.primaryColor),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 57,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Center(child: Text("12:31", style: discussionCardPlay()),),
                          width: 57,
                          height: 23,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: const Color(0xFFD74EFF)),
                        ),
                        const SizedBox(height: 8),
                        const Align(
                            alignment: Alignment.centerLeft, child: Text("32m")),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 125,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Icon(
                          Icons.rotate_90_degrees_ccw_outlined,
                          size: 25,
                        ),
                        Icon(
                          Icons.pause,
                          size: 25,
                        ),
                        Icon(
                          Icons.rotate_90_degrees_cw_outlined,
                          size: 25,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
