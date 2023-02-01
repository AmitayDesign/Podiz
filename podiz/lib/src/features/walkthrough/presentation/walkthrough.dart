import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podiz/src/features/auth/data/auth_repository.dart';
import 'package:podiz/src/features/walkthrough/data/walkthrough_repository.dart';
import 'package:podiz/src/features/walkthrough/presentation/steps/walkthrough_step.dart';
import 'package:podiz/src/localization/string_hardcoded.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:podiz/src/theme/palette.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Walkthrough extends ConsumerStatefulWidget {
  const Walkthrough({Key? key}) : super(key: key);

  @override
  ConsumerState<Walkthrough> createState() => _WalkthroughState();
}

class _WalkthroughState extends ConsumerState<Walkthrough> {
  final pageController = PageController();
  var page = 0;

  void complete() {
    final user = ref.read(currentUserProvider);
    ref.read(walkthroughRepositoryProvider).complete(user.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SmoothPageIndicator(
          controller: pageController,
          count: 3,
          effect: ScrollingDotsEffect(
            offset: 0,
            radius: 8,
            dotWidth: 8,
            dotHeight: 8,
            spacing: 6,
            activeDotScale: 1,
            dotColor: context.colorScheme.primary.withOpacity(0.2),
            activeDotColor: context.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: PageView(
            // disable swiping between pages
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            onPageChanged: (value) => setState(() => page = value),
            children: [
              WalkthroughStep(
                title: 'Play any episode'.hardcoded,
                boldTitle: 'on Podiz'.hardcoded,
                texts: [
                  'Latest episodes from your podcast are on “my Casts”'
                      .hardcoded,
                  'Trending Episode are on Trending'.hardcoded,
                  'You can also search for your favorite episode using search'
                      .hardcoded,
                ],
              ),
              WalkthroughStep(
                title: 'Or jump in'.hardcoded,
                boldTitle: 'from Spotify'.hardcoded,
                texts: [
                  'You can start by plating your favorite episode on Spotify'
                      .hardcoded,
                  'And Open Podiz when you want to join the conversation'
                      .hardcoded,
                ],
              ),
              WalkthroughStep(
                title: 'Share'.hardcoded,
                boldTitle: 'your thoughts'.hardcoded,
                texts: [
                  'When you have something to say, share it with the world!'
                      .hardcoded,
                  'Each comment is time-stamped to your playing time'.hardcoded,
                  'You can share the best comments with your friends'.hardcoded,
                ],
              ),
            ],
          ),
        ),
        if (page < 2) ...[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: Palette.deepPurple,
            ),
            onPressed: () => pageController.nextPage(
              duration: kTabScrollDuration,
              curve: Curves.ease,
            ),
            child: Text('Next'.hardcoded),
          ),
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(
              shape: const StadiumBorder(),
              foregroundColor: context.colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              minimumSize: const Size.fromHeight(56),
              textStyle: context.textTheme.titleMedium,
            ),
            onPressed: complete,
            child: Text('Skip'.hardcoded),
          ),
        ] else
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: Palette.deepPurple,
            ),
            onPressed: complete,
            child: Text('Done'.hardcoded),
          ),
      ],
    );
  }
}
