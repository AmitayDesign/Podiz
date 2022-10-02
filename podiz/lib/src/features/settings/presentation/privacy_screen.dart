import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/loading_button.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/utils/instances.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  Future<void> requestInformation(Reader read) async {
    final user = read(currentUserProvider);
    final mailDoc = read(firestoreProvider).collection('mail').doc();
    await mailDoc.set({
      'toUids': [user.id],
      'message': {
        'subject': 'Your data',
        'text': 'There you go! '
            'To download all your data just click on this link\n'
            'https://us-central1-podiz-130ca.cloudfunctions.net/requestData'
            '?id=${mailDoc.id}',
      }
    });
  }

  Future<void> whipeData(Reader read) async {
    final user = read(currentUserProvider);
    final mailDoc = read(firestoreProvider).collection('mail').doc();
    await mailDoc.set({
      'toUids': [user.id],
      'message': {
        'subject': 'Delete your data',
        //TODO create deletion link
        'text': 'There you go! '
            'To delete all your data just click on this link\n'
            'https://us-central1-podiz-130ca.cloudfunctions.net/whipeData'
            '?id=${mailDoc.id}',
      }
    });
  }

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
              const Icon(Icons.lock_rounded, color: Colors.white70),
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
                  'We are doing everything we can to keep your information yours while using the app, feel free to reach out if you have any questions'
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
                  onPressed: () => requestInformation(ref.read),
                  child: Text('REQUEST MY INFORMATION'.hardcoded),
                ),
                const SizedBox(height: 16),
                LoadingOutlinedButton(
                  color: context.colorScheme.error,
                  onPressed: () => whipeData(ref.read),
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
