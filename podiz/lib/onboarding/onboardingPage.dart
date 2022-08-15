import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/splashScreen.dart';

import 'components/onboardingAppBar.dart';
import 'connectBudz.dart';
import 'onboarding.dart';
import 'onboarding_controller.dart';

/// The sub-routes that are presented as part of the on boarding page.
enum OnboardingView { intro, connect }

/// This is the root widget of the on boarding page, which is composed of 2 views
///
/// UI updates are handled by a [PageController].
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final controller = PageController();
  var view = OnboardingView.intro;

  bool get isStartView => view == OnboardingView.intro;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void goToView(OnboardingView newView) {
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
    if (state.isLoading) return SplashScreen();

    // Return a Scaffold with a PageView containing the views.
    // This allows for a nice scroll animation when switching between pages.
    // Note: only the currently active view will be visible.
    return WillPopScope(
      onWillPop: () async {
        if (isStartView) return true;
        goToView(OnboardingView.intro);
        return false;
      },
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgroundImage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          appBar: const OnboardingAppBar(),
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
                    children: const [Onboarding(), ConnectBudz()],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 16,
                  ),
                  child: ElevatedButton(
                    onPressed: () => isStartView
                        ? goToView(OnboardingView.connect)
                        : ref
                            .read(onboardingControllerProvider.notifier)
                            .signIn(),
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
