import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

abstract class NameFieldValidator {
  static String? validate(BuildContext context, String value) {
    if (value.length < 2) return Locales.string(context, "validate1");
    if (value.length > 32) return Locales.string(context, "validate2");
    return null;
  }
}

abstract class EmailFieldValidator {
  static String get _pattern =>
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  static RegExp get _regex => RegExp(_pattern);
  static String? validate(BuildContext context, String value) {
    if (!_regex.hasMatch(value)) return Locales.string(context, "validate3");
    return null;
  }
}

abstract class PasswordFieldValidator {
  static String? validate(BuildContext context, String value) {
    if (value.length < 6)
      return Locales.string(context, "validate9");
    else if (value.length > 20) return Locales.string(context, "validate10");
    return null;
  }

  static String? confirm(BuildContext context, String value, String password) {
    if (value != password) return Locales.string(context, "validate11");
    return null;
  }
}

//!

class DescriptionFieldValidator {
  static String? error;
  static String? validate(BuildContext context, String value) {
    if (value.length > 250) return Locales.string(context, "validate1");
    return error;
  }
}