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

  //TODO change sender
  Future<void> requestInformation(Reader read) async {
    final user = read(currentUserProvider);
    await read(firestoreProvider).collection('mail').add({
      'to': user.email,
      // 'toUids': [user.id],
      'message': {
        //TODO subject and text
        'subject': 'Your data',
        'text': 'There you go! A zip filw with your data is attached bellow',
        //TODO make a zip with all the user data
        //TODO search 'node mailer zip attachment and see how to add it here
        //TODO make the button load and/or prompt a 'you ll receive an email soon'
        // 'attachments': [],
      }
    });
  }

  Future<void> whipeData(Reader read) async {
    final user = read(currentUserProvider);
    await read(firestoreProvider).collection('mail').add({
      'to': user.email,
      // 'toUids': [user.id],
      'message': {
        //TODO subject and text
        'subject': 'Delete your data',
        //TODO create deletion link
        'text': 'There you go! To delete all your data just click on this link',
        // 'attachments': [],
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
