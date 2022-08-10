import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgIcon extends StatelessWidget {
  final String asset;
  final Color? color;
  final double? size;

  const SvgIcon(this.asset, {Key? key, this.color, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      height: size ?? IconTheme.of(context).size,
      color: color ?? IconTheme.of(context).color,
    );
  }
}