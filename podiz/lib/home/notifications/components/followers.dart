import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:podiz/aspect/constants.dart';

class Followers extends StatelessWidget {
  int followers, following, saved;

  Followers(this.followers, this.following, this.saved, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 360,
      height: 62,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(followers.toString(), style: theme.textTheme.headline6),
            Text(
              Locales.string(context, "followers"),
              style: theme.textTheme.caption,
            ),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(following.toString(), style: theme.textTheme.headline6),
            Text(
              Locales.string(context, "following"),
              style: theme.textTheme.caption,
            ),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(saved.toString(), style: theme.textTheme.headline6),
            Text(
              Locales.string(context, "saved"),
              style: theme.textTheme.caption,
            ),
          ])
        ],
      ),
    );
  }
}
