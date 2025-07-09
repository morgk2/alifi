import 'package:flutter/material.dart';
import 'dart:ui';

class BaseDialog extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color barrierColor;

  const BaseDialog({
    super.key,
    required this.child,
    this.blur = 5,
    this.barrierColor = Colors.black38,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}
