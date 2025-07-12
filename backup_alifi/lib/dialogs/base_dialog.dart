import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/device_performance.dart';

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
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width * 0.9; // 90% of screen width
    final maxHeight = screenSize.height * 0.9; // 90% of screen height
    
    // Get optimized blur value based on device performance
    final optimizedBlur = DevicePerformance().getBlurSigma(blur);

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: optimizedBlur,
        sigmaY: optimizedBlur,
      ),
      child: Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: child,
          ),
        ),
      ),
    );
  }
}
