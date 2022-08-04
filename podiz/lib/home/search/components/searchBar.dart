import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:podiz/aspect/widgets/suffixIcon.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const SearchBar({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: Locales.string(context, "search1"),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        prefixIcon: Icon(LucideIcons.search),
        suffixIcon: controller.text.isNotEmpty
            ? SuffixIcon(LucideIcons.x, onTap: () => controller.text = '')
            : null,
      ),
    );
  }
}
