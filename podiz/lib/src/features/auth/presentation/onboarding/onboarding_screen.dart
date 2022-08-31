import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/common_widgets/loading_button.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/context_theme.dart';

import 'connect_page.dart';
import 'intro_page.dart';
import 'onboarding_bar.dart';
import 'onboarding_controller.dart';

/// The sub-routes that are presented as part of the on boarding page.
enum OnboardingPage { intro, connect }

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

  bool get isStartView => view == OnboardingPage.intro;

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
    ref.listen<AsyncValue>(onboardingControllerProvider, (_, state) {
      if (!state.isRefreshing && state.hasError) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(state.error.toString()),
          ),
        );
      }
    });
    final state = ref.watch(onboardingControllerProvider);

    // Return a Scaffold with a PageView containing the views.
    // This allows for a nice scroll animation when switching between pages.
    // Note: only the currently active view will be visible.
    return WillPopScope(
      onWillPop: () async {
        if (isStartView) return true;
        goToView(OnboardingPage.intro);
        return false;
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: PageView(
                    // disable swiping between pages
                    physics: const NeverScrollableScrollPhysics(),
                    controller: controller,
                    children: const [IntroPage(), ConnectPage()],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 16,
                  ),
                  child: LoadingElevatedButton(
                    loading: state.isLoading,
                    onPressed: () => isStartView
                        ? goToView(OnboardingPage.connect)
                        : context.pushNamed(AppRoute.signIn.name),
                    child: Text(
                      isStartView
                          ? Locales.string(context, "intro2")
                          : Locales.string(context, "intro4"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
