// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SpotifyIcon extends StatelessWidget {
  final double size;
  final Color? color;
  const SpotifyIcon({Key? key, this.size = 24, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/icons/spotify.svg",
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
    );
  }
}
