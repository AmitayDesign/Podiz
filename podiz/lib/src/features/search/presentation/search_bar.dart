import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/suffix_icon.dart';
import 'package:podiz/src/theme/context_theme.dart';

class SearchBar extends StatelessWidget with PreferredSizeWidget {
  final TextEditingController controller;
  const SearchBar({Key? key, required this.controller}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(GradientBar.backgroundHeight);

  String get query => controller.text;

  @override
  Widget build(BuildContext context) {
    return GradientBar(
      title: ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, value, _) {
            return TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              style: context.textTheme.bodyMedium!.copyWith(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: Locales.string(context, "search1"),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isEmpty
                    ? const SizedBox.shrink()
                    : SuffixIcon(Icons.close_rounded, onTap: controller.clear),
              ),
            );
          }),
    );
  }
}
