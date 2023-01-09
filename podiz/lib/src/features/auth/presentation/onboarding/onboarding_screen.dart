import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/auth/presentation/connection_controller.dart';
import 'package:podiz/src/features/auth/presentation/onboarding/email_page.dart';
import 'package:podiz/src/features/auth/presentation/onboarding/onboarding_controller.dart';
import 'package:podiz/src/features/notifications/data/push_notifications_repository.dart';
import 'package:podiz/src/features/splash/presentation/splash_screen.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';

import 'budz_page.dart';
import 'intro_page.dart';
import 'onboarding_bar.dart';

/// The sub-routes that are presented as part of the on boarding page.
enum OnboardingPage { intro, budz, email }

/// This is the root widget of the on boarding page, which is composed of 2 pages
///
/// UI updates are handled by a [PageController].
class OnboardingScreen extends ConsumerStatefulWidget {
  final OnboardingPage? page;
  const OnboardingScreen({Key? key, this.page}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late var page = widget.page ?? OnboardingPage.intro;
  late var controller = PageController(initialPage: page.index);

  final emailController = TextEditingController();
  String get email => emailController.text;

  @override
  void didUpdateWidget(covariant OnboardingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("did change dependecy");
    if (widget.page != null) {
      page = widget.page!;
      controller = PageController(initialPage: page.index);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    controller.dispose();
    super.dispose();
  }

  void goToPage(OnboardingPage newPage) {
    setState(() => page = newPage);
    // perform a nice scroll animation to reveal the next page
    controller.animateToPage(
      page.index,
      duration: kTabScrollDuration,
      curve: Curves.ease,
    );
  }

  Future<void> signIn() =>
      ref.read(connectionControllerProvider.notifier).signIn();

  @override
  Widget build(BuildContext context) {
    print(page);
    print(widget.page);
    //TODO onboarding error popup
    ref.listen(
      onboardingControllerProvider,
      (_, state) => print('ERROR UPDATING EMAIL'),
    );

    final state = ref.watch(connectionControllerProvider);
    if (state.isLoading) {
      return const SplashScreen();
    } else if (!state.isRefreshing && state.hasError) {
      return SplashScreen.error(onRetry: signIn);
    }
    // Return a Scaffold with a PagePage containing the pages.
    // This allows for a nice scroll animation when switching between pages.
    // Note: only the currently active page will be visible.
    return WillPopScope(
      onWillPop: () async {
        switch (page) {
          case OnboardingPage.intro:
            return true;
          case OnboardingPage.budz:
            goToPage(OnboardingPage.intro);
            return false;
          case OnboardingPage.email:
            final user = ref.read(currentUserProvider);
            ref
                .read(pushNotificationsRepositoryProvider)
                .revokePermission(user.id);
            ref.read(authRepositoryProvider).signOut();
            return false;
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.background,
          image: const DecorationImage(
            image: AssetImage('assets/images/backgroundImage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          appBar: const OnboardingBar(),
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    // disable swiping between pages
                    physics: const NeverScrollableScrollPhysics(),
                    controller: controller,
                    children: [
                      const IntroPage(),
                      const BudzPage(),
                      EmailPage(controller: emailController),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (page == OnboardingPage.intro)
                  ElevatedButton(
                    onPressed: () => goToPage(OnboardingPage.budz),
                    child: const LocaleText('intro2'),
                  )
                else if (page == OnboardingPage.budz)
                  ElevatedButton(
                    onPressed: signIn,
                    child: const LocaleText('intro4'),
                  )
                else //* OnboardingPage.email
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(onboardingControllerProvider.notifier)
                          .setEmail(email);
                    },
                    child: Text('Save'.hardcoded),
                  ),
                if (Platform.isIOS) const SizedBox(height: 16)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
