import 'package:flutter/material.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';

class EmailPage extends StatelessWidget {
  final TextEditingController? controller;
  const EmailPage({Key? key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 360,
            minHeight: constraints.maxHeight,
          ),
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 24,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.background,
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter Your Email Address".hardcoded,
                  style: context.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "We need your email to provide helpful information and help you recover your accounts if needed. We hate spam too."
                      .hardcoded,
                  style: context.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'example@mail.com',
                  ),
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "We'll send a verification email to your address".hardcoded,
                  style: context.textTheme.bodySmall!
                      .copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
