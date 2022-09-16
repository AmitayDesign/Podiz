import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/context_theme.dart';

import 'budz_page.dart';
import 'intro_page.dart';
import 'onboarding_bar.dart';

/// The sub-routes that are presented as part of the on boarding page.
enum OnboardingPage { intro, budz }

/// This is the root widget of the on boarding page, which is composed of 2 pages
///
/// UI updates are handled by a [PageController].
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final controller = PageController();
  var page = OnboardingPage.intro;

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
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
                    children: const [
                      IntroPage(),
                      BudzPage(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (page == OnboardingPage.intro)
                  ElevatedButton(
                    onPressed: () => goToPage(OnboardingPage.budz),
                    child: const LocaleText('intro2'),
                  )
                else
                  ElevatedButton(
                    onPressed: () => context.goNamed(AppRoute.connect.name),
                    child: const LocaleText('intro4'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
