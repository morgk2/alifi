import 'package:flutter/material.dart';

class SpinningLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const SpinningLoader({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  State<SpinningLoader> createState() => _SpinningLoaderState();
}

class _SpinningLoaderState extends State<SpinningLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Image.asset(
        'assets/images/loading.png',
        width: widget.size,
        height: widget.size,
        color: widget.color,
      ),
    );
  }
} 