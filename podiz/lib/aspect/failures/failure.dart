import 'package:flutter/widgets.dart';
import 'package:flutter_locales/flutter_locales.dart';

class Failure implements Exception {
  final String code;
  final String message;
  const Failure({required this.code, required this.message});

  factory Failure.unexpected(BuildContext context) => Failure(
        code: 'unexpected',
        message: Locales.string(context, "failure1"),
      );

  factory Failure.noConection(BuildContext context) => Failure(
        code: 'no-connection',
        message: Locales.string(context, "failure2"),
      );
}
