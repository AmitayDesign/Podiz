import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/loading_button.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/utils/instances.dart';

//TODO put on the correct file
const notificationsKey = 'notifications-setting';
final notificationsValueStreamProvider = StreamProvider<bool>((ref) {
  final preferences = ref.watch(preferencesProvider);
  return preferences.getBool(notificationsKey, defaultValue: true);
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final preferences = ref.watch(preferencesProvider);
    final notificationsValue =
        ref.watch(notificationsValueStreamProvider).valueOrNull ?? true;
    return Scaffold(
      appBar: const GradientBar(
        automaticallyImplyLeading: false,
        title: BackTextButton(),
      ),
      body: Column(
        children: [
          //* Profile
          UserAvatar(user: user, radius: 48, enableNavigation: false),
          const SizedBox(height: 12),
          Text(user.name, style: context.textTheme.titleLarge),
          const SizedBox(height: 32),

          //* Settings
          SwitchListTile(
            value: notificationsValue,
            onChanged: (value) {
              preferences.setBool(notificationsKey, value);
              //TODO enable/disable notifications
            },
            tileColor: context.colorScheme.surface,
            secondary: const Icon(Icons.notifications, color: Colors.white70),
            title: Text(
              'Notifications',
              style: context.textTheme.titleMedium!
                  .copyWith(color: Colors.white70),
            ),
            controlAffinity: ListTileControlAffinity.trailing,
          ),
          const SizedBox(height: 8),
          ListTile(
            onTap: () => context.goNamed(AppRoute.privacy.name),
            tileColor: context.colorScheme.surface,
            leading: const Icon(Icons.lock, color: Colors.white70),
            title: Text(
              'Privacy',
              style: context.textTheme.titleMedium!
                  .copyWith(color: Colors.white70),
            ),
          ),
          const Spacer(),

          //* Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                LoadingOutlinedButton(
                  onPressed: () => ref.read(authRepositoryProvider).signOut(),
                  child: Text('LOG OUT'.hardcoded),
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    text: 'We\'re keeping your back safe. check it out in our'
                        .hardcoded
                        .toUpperCase(),
                    style: context.textTheme.bodySmall,
                    children: [
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: 'privacy policy'.hardcoded.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {}, //!
                      ),
                      TextSpan(text: ' and '.hardcoded.toUpperCase()),
                      TextSpan(
                        text: 'terms of use'.hardcoded.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {}, //!
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
