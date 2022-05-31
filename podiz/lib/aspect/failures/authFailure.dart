import 'package:podiz/aspect/failures/failure.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_locales/flutter_locales.dart';

class AuthFailure extends Failure {
  AuthFailure._({
    required String code,
    required String message,
  }) : super(code: code, message: message);

  factory AuthFailure.emailAlreadyInUse(BuildContext context) => AuthFailure._(
        code: 'email-already-in-use',
        message: Locales.string(context, 'registerfailure1'),
      );

  factory AuthFailure.weekPassword(BuildContext context) => AuthFailure._(
        code: 'email-already-in-use',
        message: Locales.string(context, 'registerfailure1'),
      );

  factory AuthFailure.wrongPassword(BuildContext context) => AuthFailure._(
        code: 'wrong-password',
        message: Locales.string(context, 'loginfailure1'),
      );

  factory AuthFailure.userNotFound(BuildContext context) => AuthFailure._(
        code: 'user-not-found',
        message: Locales.string(context, 'loginfailure2'),
      );

  factory AuthFailure.tooManyRequests(BuildContext context) => AuthFailure._(
        code: 'too-many-requests',
        message: Locales.string(context, 'loginfailure3'),
      );
}
