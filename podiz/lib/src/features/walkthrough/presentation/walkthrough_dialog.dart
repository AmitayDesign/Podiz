import 'package:flutter/material.dart';
import 'package:podiz/src/features/walkthrough/presentation/walkthrough.dart';

Future<bool?> showWalkthroughDialog({
  required BuildContext context,
}) =>
    showDialog(
      context: context,
      builder: (context) => const Dialog(
        insetPadding: EdgeInsets.all(16),
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Walkthrough(),
        ),
      ),
    );
