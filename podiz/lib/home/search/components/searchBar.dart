import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:podiz/aspect/widgets/gradientAppBar.dart';
import 'package:podiz/aspect/widgets/suffixIcon.dart';

class SearchBar extends StatelessWidget with PreferredSizeWidget {
  final TextEditingController controller;
  const SearchBar({Key? key, required this.controller}) : super(key: key);

  @override
  Size get preferredSize =>
      const Size.fromHeight(GradientAppBar.backgroundHeight);

  String get query => controller.text;

  @override
  Widget build(BuildContext context) {
    return GradientAppBar(
      title: ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, value, _) {
            return TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: Locales.string(context, "search1"),
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: query.isEmpty
                    ? const SizedBox.shrink()
                    : SuffixIcon(LucideIcons.x, onTap: controller.clear),
              ),
            );
          }),
    );
  }
}
