import 'package:flutter/material.dart';
import 'dart:math';

class VerificationBadge extends StatelessWidget {
  final double size;
  final Color? color;

  const VerificationBadge({
    super.key,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: ScallopedCirclePainter(
        color: color ?? const Color(0xFF87CEEB), // Light blue
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: size * 0.65,
          weight: 800,
        ),
      ),
    );
  }
}

class ProfileVerificationBadge extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const ProfileVerificationBadge({
    super.key,
    this.size = 20,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // Use light blue as the main color, iconColor is now used as the badge background
    final badgeColor = iconColor ?? const Color(0xFF87CEEB); // Light blue
    
    return CustomPaint(
      size: Size(size, size),
      painter: ScallopedCirclePainter(
        color: badgeColor,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: size * 0.65,
          weight: 800,
        ),
      ),
    );
  }
}

class ScallopedCirclePainter extends CustomPainter {
  final Color color;

  ScallopedCirclePainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final int scallopCount = 10; // Number of scallops (reduced for better circular arcs)
    final double radius = size.width / 2;
    final double innerRadius = radius * 0.8; // Inner radius for the valleys
    final Offset center = Offset(size.width / 2, size.height / 2);

    final Path path = Path();

    // Create the scalloped path with circular arcs
    for (int i = 0; i < scallopCount; i++) {
      final double startAngle = (2 * pi * i) / scallopCount;
      final double endAngle = (2 * pi * (i + 1)) / scallopCount;
      final double midAngle = (startAngle + endAngle) / 2;

      // Calculate points on the inner circle (valleys)
      final double startX = center.dx + innerRadius * cos(startAngle);
      final double startY = center.dy + innerRadius * sin(startAngle);
      final double endX = center.dx + innerRadius * cos(endAngle);
      final double endY = center.dy + innerRadius * sin(endAngle);

      // Calculate the peak point (outward bump)
      final double peakX = center.dx + radius * cos(midAngle);
      final double peakY = center.dy + radius * sin(midAngle);

      if (i == 0) {
        path.moveTo(startX, startY);
      }

      // Create a smooth arc from valley to peak to valley using quadratic bezier
      path.quadraticBezierTo(
        peakX,
        peakY,
        endX,
        endY,
      );
    }

    path.close();

    // Draw the main scalloped circle
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 