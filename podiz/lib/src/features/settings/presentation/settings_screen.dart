import 'package:app_settings/app_settings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/common_widgets/back_text_button.dart';
import 'package:podiz/src/common_widgets/gradient_bar.dart';
import 'package:podiz/src/common_widgets/loading_button.dart';
import 'package:podiz/src/common_widgets/user_avatar.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/notifications/data/push_notifications_repository.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';

import 'settings_controller.dart';

//TODO refact
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final emailController = TextEditingController(
    text: ref.read(currentUserProvider).email!,
  );

  String get email => emailController.text;

  /// Screen height- status bar height - app bar height
  double get bodyHeight {
    final mq = MediaQuery.of(context);
    return mq.size.height - mq.padding.top - GradientBar.backgroundHeight;
  }

  void saveEmail() =>
      ref.read(settingsControllerProvider.notifier).saveEmail(email);

  @override
  Widget build(BuildContext context) {
    //TODO settings error popup
    ref.listen(
      settingsControllerProvider,
      (_, state) => print('ERROR UPDATING EMAIL'),
    );
    final user = ref.watch(currentUserProvider);
    final state = ref.watch(settingsControllerProvider);
    return Scaffold(
      appBar: const GradientBar(
        automaticallyImplyLeading: false,
        title: BackTextButton(),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: bodyHeight,
          child: Column(
            children: [
              //* Profile
              UserAvatar(user: user, radius: 48, enableNavigation: false),
              const SizedBox(height: 12),
              Text(user.name, style: context.textTheme.titleLarge),
              const SizedBox(height: 32),

              //* Email
              ValueListenableBuilder(
                  valueListenable: emailController,
                  child: TextField(
                    enabled: !state.isLoading,
                    controller: emailController,
                    style: context.textTheme.titleMedium!
                        .copyWith(color: Colors.white70),
                    decoration: const InputDecoration(
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  builder: (context, _, textField) {
                    return ListTile(
                      tileColor: context.colorScheme.surface,
                      leading: const Icon(Icons.alternate_email,
                          color: Colors.white70),
                      title: textField,
                      trailing: state.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(3),
                              child: SizedBox.square(
                                dimension: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 3),
                              ),
                            )
                          : user.email == email
                              ? null
                              : TextButton(
                                  onPressed: saveEmail,
                                  child: Text(
                                    'Save'.hardcoded,
                                    style: context.textTheme.titleSmall!
                                        .copyWith(color: Palette.purple),
                                  ),
                                ),
                    );
                  }),
              const SizedBox(height: 8),

              //* Notifications
              ListTile(
                onTap: AppSettings.openNotificationSettings,
                tileColor: context.colorScheme.surface,
                leading: const Icon(Icons.notifications_rounded,
                    color: Colors.white70),
                title: Text(
                  'Notifications',
                  style: context.textTheme.titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 8),

              //* Privacy
              ListTile(
                onTap: () => context.goNamed(AppRoute.privacy.name),
                tileColor: context.colorScheme.surface,
                leading: const Icon(Icons.lock_rounded, color: Colors.white70),
                title: Text(
                  'Privacy',
                  style: context.textTheme.titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),
              const Spacer(),

              Text(
                'Illustrations by https://icons8.com',
                style: context.textTheme.labelSmall!.copyWith(fontSize: 8),
              ),

              //* Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    LoadingOutlinedButton(
                      onPressed: () {
                        //! create auth service
                        final user = ref.read(currentUserProvider);
                        ref
                            .read(pushNotificationsRepositoryProvider)
                            .revokePermission(user.id);
                        ref.read(authRepositoryProvider).signOut();
                      },
                      child: Text('LOG OUT'.hardcoded),
                    ),
                    const SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        text:
                            'We\'re keeping your back safe. check it out in our'
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
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {}, //!
                          ),
                          TextSpan(text: ' and '.hardcoded.toUpperCase()),
                          TextSpan(
                            text: 'terms of use'.hardcoded.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {}, //!
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
        ),
      ),
    );
  }
}
