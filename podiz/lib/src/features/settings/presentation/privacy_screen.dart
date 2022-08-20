import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/loadingButton.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const GradientBar(
        automaticallyImplyLeading: false,
        title: BackTextButton(),
      ),
      body: Column(
        children: [
          //* Profile
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                'Privacy',
                style: context.textTheme.titleMedium!
                    .copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              text:
                  'We are doing everything we can to keep your information yours while using the app, feel frre to reach out if you have any questions'
                      .hardcoded,
              children: const [
                TextSpan(text: '\n'),
                TextSpan(
                  text: 'Amitay@Podiz.com',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),

          //* Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                LoadingOutlinedButton(
                  onPressed: () {}, //!
                  child: Text('REQUEST MY INFORMATION'.hardcoded),
                ),
                const SizedBox(height: 16),
                LoadingOutlinedButton(
                  color: context.colorScheme.error,
                  onPressed: () {}, //!
                  child: Text('WHIPE MY DATA'.hardcoded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
