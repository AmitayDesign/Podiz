import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

void showErrorBar(BuildContext context, String message) {
  final theme = Theme.of(context);
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.GROUNDED,
    duration: const Duration(seconds: 4),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    backgroundColor: theme.colorScheme.error,
    icon: Icon(LucideIcons.alertCircle, color: theme.colorScheme.onError),
    shouldIconPulse: false,
    messageText: Text(
      message,
      style: TextStyle(color: theme.colorScheme.onError),
    ),
  ).show(context);
}
