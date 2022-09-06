import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/theme/context_theme.dart';

import 'budz_page.dart';
import 'connect_page.dart';
import 'intro_page.dart';
import 'onboarding_bar.dart';

/// The sub-routes that are presented as part of the on boarding page.
enum OnboardingPage { intro, budz, connect }

extension OnboardingPageX on OnboardingPage {
  T when<T>({
    T Function()? intro,
    T Function()? budz,
    T Function()? connect,
  }) {
    switch (this) {
      case OnboardingPage.intro:
        if (intro != null) return intro();
        throw Exception('Missing intro implementation');
      case OnboardingPage.budz:
        if (budz != null) return budz();
        throw Exception('Missing budz implementation');
      case OnboardingPage.connect:
        if (connect != null) return connect();
        throw Exception('Missing connect implementation');
    }
  }
}

/// This is the root widget of the on boarding page, which is composed of 2 views
///
/// UI updates are handled by a [PageController].
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final controller = PageController();
  var view = OnboardingPage.intro;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void goToView(OnboardingPage newView) {
    setState(() => view = newView);
    // perform a nice scroll animation to reveal the next view
    controller.animateToPage(
      view.index,
      duration: kTabScrollDuration,
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Return a Scaffold with a PageView containing the views.
    // This allows for a nice scroll animation when switching between pages.
    // Note: only the currently active view will be visible.
    return WillPopScope(
      onWillPop: () async => view.when(
        intro: () => true,
        budz: () {
          goToView(OnboardingPage.intro);
          return false;
        },
        connect: () {
          goToView(OnboardingPage.budz);
          return false;
        },
      ),
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
          body: PageView(
            // disable swiping between pages
            physics: const NeverScrollableScrollPhysics(),
            controller: controller,
            children: [
              IntroPage(
                onSuccess: () => goToView(OnboardingPage.budz),
              ),
              BudzPage(
                onSuccess: () => goToView(OnboardingPage.connect),
              ),
              const ConnectPage(),
            ],
          ),
        ),
      ),
    );
  }
}
