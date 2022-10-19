import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podiz/src/routing/app_router.dart';
import 'package:podiz/src/theme/context_theme.dart';

class EmptyNotifications extends StatelessWidget {
  const EmptyNotifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Notifications will appear when someone replies to your comments.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    'assets/images/onBoardingMen.png',
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Start commenting and see what your friends think!',
                    style: context.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => context.goNamed(AppRoute.home.name),
            child: const Text('Go to home page'),
          ),
        ],
      ),
    );
  }
}
