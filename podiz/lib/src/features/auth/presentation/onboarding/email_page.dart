import 'package:flutter/material.dart';
import 'package:podiz/src/constants/constants.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';

class EmailPage extends StatelessWidget {
  final VoidCallback? onSuccess;
  const EmailPage({Key? key, this.onSuccess}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
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
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter Your Email Address".hardcoded,
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "We need your email to provide helpful information and help you recover your accounts if needed. We hate spam too"
                  .hardcoded,
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            //TODO add textField
            const SizedBox(height: 32),
            ElevatedButton(
                onPressed: () {},
                child: Text("SEND".hardcoded)), //TODO add logic in this part
          ],
        ),
      ),
    );
  }
}
