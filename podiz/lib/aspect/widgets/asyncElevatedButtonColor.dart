import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:podiz/aspect/constants.dart';

class AsyncElevatedButtonColor extends StatefulWidget {
  final AsyncCallback? onPressed;
  final List<Widget> children;
  final Color color;

  const AsyncElevatedButtonColor(
      {Key? key,
      required this.onPressed,
      required this.color,
      required this.children})
      : super(key: key);

  @override
  State<AsyncElevatedButtonColor> createState() =>
      _AsyncElevatedButtonColorState();
}

class _AsyncElevatedButtonColorState extends State<AsyncElevatedButtonColor> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: widget.color,
        ),
        width: 360,
        height: 40,
        child: InkWell(
            onTap: widget.onPressed == null
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.children,
                  )),
      ),
    );
  }
}
