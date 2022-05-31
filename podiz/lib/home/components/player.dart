import 'package:flutter/material.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:podiz/aspect/constants.dart';

class Player extends StatefulWidget {
  Player({Key? key}) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}

final MiniplayerController controller = MiniplayerController();

class _PlayerState extends State<Player> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Miniplayer(
      controller: controller,
      onDismiss: () {},
      minHeight: 100,
      maxHeight: kScreenHeight,
      builder: ((height, percentage) => Container(
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
                          child: const Center(child: Text("12:31")),
                          width: 57,
                          height: 23,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: const Color(0xFFD74EFF)),
                        ),
                        const SizedBox(height: 8),
                        const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("32m")),
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
          )),
    );
  }
}
