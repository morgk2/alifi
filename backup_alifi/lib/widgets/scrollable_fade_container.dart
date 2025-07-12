import 'package:flutter/material.dart';

class ScrollableFadeContainer extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  final double containerWidth;
  final double contentWidth;

  const ScrollableFadeContainer({
    super.key,
    required this.child,
    required this.scrollController,
    required this.containerWidth,
    required this.contentWidth,
  });

  @override
  State<ScrollableFadeContainer> createState() =>
      _ScrollableFadeContainerState();
}

class _ScrollableFadeContainerState extends State<ScrollableFadeContainer> {
  bool _showLeftFade = false;
  bool _showRightFade = true;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateFades);
    _updateFades();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateFades);
    super.dispose();
  }

  void _updateFades() {
    if (!mounted || !widget.scrollController.hasClients) return;

    final hasMoreLeft = widget.scrollController.offset > 0;
    final hasMoreRight = widget.scrollController.offset <
        widget.scrollController.position.maxScrollExtent;

    if (_showLeftFade != hasMoreLeft || _showRightFade != hasMoreRight) {
      setState(() {
        _showLeftFade = hasMoreLeft;
        _showRightFade = hasMoreRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show fades if there's actually content that overflows
    final bool hasOverflow = widget.contentWidth > widget.containerWidth;

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _showLeftFade && hasOverflow
                ? Colors.white
                : Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.0),
            _showRightFade && hasOverflow
                ? Colors.white
                : Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 0.05, 0.95, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstOut,
      child: widget.child,
    );
  }
}
