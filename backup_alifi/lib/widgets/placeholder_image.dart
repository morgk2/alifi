import 'package:flutter/material.dart';

class PlaceholderImage extends StatelessWidget {
  final double width;
  final double height;
  final bool isCircular;
  final double borderRadius;

  const PlaceholderImage({
    super.key,
    required this.width,
    required this.height,
    this.isCircular = false,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: !isCircular ? BorderRadius.circular(borderRadius) : null,
      ),
      child: Icon(
        Icons.camera_alt,
        color: Colors.grey[600],
        size: width * 0.4,
      ),
    );
  }
}
