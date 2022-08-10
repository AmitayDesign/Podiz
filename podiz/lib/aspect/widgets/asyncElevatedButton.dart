import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';

class AsyncElevatedButton extends StatefulWidget {
  final AsyncCallback? onPressed;
  final Widget child;
  const AsyncElevatedButton(
      {Key? key, required this.onPressed, required this.child})
      : super(key: key);

  @override
  State<AsyncElevatedButton> createState() => _AsyncElevatedButtonState();
}

class _AsyncElevatedButtonState extends State<AsyncElevatedButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: widget.onPressed == null
          ? null
          : () async {
              if (isLoading) return;
              if (mounted) setState(() => isLoading = true);
              await widget.onPressed!();
              if (mounted) setState(() => isLoading = false);
            },
      child: isLoading
          ? SizedBox.square(
              dimension: kSmallIconSize,
              child: CircularProgressIndicator(
                color: theme.colorScheme.onPrimary,
                strokeWidth: 2,
              ),
            )
          : widget.child,
    );
  }
}
