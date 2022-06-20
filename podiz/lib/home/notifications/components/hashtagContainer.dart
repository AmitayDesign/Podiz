import 'package:flutter/material.dart';

class HashtagContainer extends StatelessWidget {
  String text;
  Color color;
  HashtagContainer(this.text, this.color, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: color,
          
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              text,
              style: theme.textTheme.bodyText2,
            ),
          ),
        ),
      ),
    );
  }
}

class HashtagContainerMock extends StatelessWidget {
  const HashtagContainerMock({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HashtagContainer("#Business & Technology", const Color(0xFF1F93B5) ),
        HashtagContainer("#Music",const Color(0xFFC63ABB)),

      ],
    );
  }
}

class HashtagContainerMock2 extends StatelessWidget {
  const HashtagContainerMock2({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HashtagContainer("#Business & Technology", const Color(0xFF1F93B5) ),
        HashtagContainer("#Music",const Color(0xFFC63ABB)),

      ],
    );
  }
}
