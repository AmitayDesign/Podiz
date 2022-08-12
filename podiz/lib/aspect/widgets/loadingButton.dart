import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';

/// Loading button based on [ElevatedButton].
/// Useful for CTAs in the app.
/// @param child - child to display on the button, usually a Text widget.
/// @param loading - if true, a loading indicator will be displayed instead of
/// the text.
/// @param onPressed - callback to be called when the button is pressed.
class LoadingElevatedButton extends StatelessWidget {
  final Widget child;
  final bool loading;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  const LoadingElevatedButton({
    Key? key,
    required this.child,
    this.loading = false,
    this.onPressed,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox.square(
              dimension: kSmallIconSize,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : child,
    );
  }
}

/// Loading button based on [OutlinedButton].
/// Useful for CTAs in the app.
/// @param child - child to display on the button, usually a Text widget.
/// @param loading - if true, a loading indicator will be displayed instead of
/// the text.
/// @param onPressed - callback to be called when the button is pressed.
class LoadingOutlinedButton extends StatelessWidget {
  final Widget child;
  final bool loading;
  final VoidCallback? onPressed;

  const LoadingOutlinedButton({
    Key? key,
    required this.child,
    this.loading = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox.square(
              dimension: kSmallIconSize,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : child,
    );
  }
}

/// Loading button based on [TextButton].
/// Useful for CTAs in the app.
/// @param child - child to display on the button, usually a Text widget.
/// @param loading - if true, a loading indicator will be displayed instead of
/// the text.
/// @param onPressed - callback to be called when the button is pressed.
class LoadingTextButton extends StatelessWidget {
  final Widget child;
  final bool loading;
  final VoidCallback? onPressed;

  const LoadingTextButton({
    Key? key,
    required this.child,
    this.loading = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox.square(
              dimension: kSmallIconSize,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : child,
    );
  }
}
