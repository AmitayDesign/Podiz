import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:podiz/aspect/widgets/suffixIcon.dart';

class SearchBar extends StatelessWidget with PreferredSizeWidget {
  final TextEditingController controller;
  const SearchBar({Key? key, required this.controller}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      title: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: Locales.string(context, "search1"),
          prefixIcon: const Icon(LucideIcons.search),
          suffixIcon: controller.text.isNotEmpty
              ? SuffixIcon(LucideIcons.x, onTap: () => controller.text = '')
              : null,
        ),
      ),
    );
  }
}
