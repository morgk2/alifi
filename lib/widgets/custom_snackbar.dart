import 'dart:ui';
import 'package:flutter/material.dart';

/// Custom SnackBar with modern Material 3 design
/// Features: rounded corners, blurred background, smooth animations
class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    super.key,
    required String message,
    CustomSnackBarType type = CustomSnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) : super(
          content: _CustomSnackBarContent(
            message: message,
            type: type,
            onAction: onAction,
            actionLabel: actionLabel,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          dismissDirection: DismissDirection.down,
        );
}

enum CustomSnackBarType { success, error, info }

class _CustomSnackBarContent extends StatefulWidget {
  final String message;
  final CustomSnackBarType type;
  final VoidCallback? onAction;
  final String? actionLabel;

  const _CustomSnackBarContent({
    required this.message,
    required this.type,
    this.onAction,
    this.actionLabel,
  });

  @override
  State<_CustomSnackBarContent> createState() => _CustomSnackBarContentState();
}

class _CustomSnackBarContentState extends State<_CustomSnackBarContent>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case CustomSnackBarType.success:
        return Colors.green.withOpacity(0.9);
      case CustomSnackBarType.error:
        return Colors.red.withOpacity(0.9);
      case CustomSnackBarType.info:
        return Colors.grey[800]!.withOpacity(0.9);
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case CustomSnackBarType.success:
        return Icons.check_circle_outline;
      case CustomSnackBarType.error:
        return Icons.error_outline;
      case CustomSnackBarType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    _icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (widget.onAction != null && widget.actionLabel != null) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: widget.onAction,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        widget.actionLabel!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper class for showing custom SnackBars
class CustomSnackBarHelper {
  /// Show a success SnackBar
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        message: message,
        type: CustomSnackBarType.success,
        duration: duration,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );
  }

  /// Show an error SnackBar
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        message: message,
        type: CustomSnackBarType.error,
        duration: duration,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );
  }

  /// Show an info SnackBar
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        message: message,
        type: CustomSnackBarType.info,
        duration: duration,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );
  }

  /// Show a SnackBar with custom type
  static void show(
    BuildContext context,
    String message, {
    CustomSnackBarType type = CustomSnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        message: message,
        type: type,
        duration: duration,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );
  }
}













