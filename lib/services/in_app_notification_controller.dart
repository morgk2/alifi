import 'package:flutter/material.dart';
import 'navigation_service.dart';
import '../widgets/in_app_notification_banner.dart';

class InAppNotificationController {
  static final InAppNotificationController _instance = InAppNotificationController._internal();
  factory InAppNotificationController() => _instance;
  InAppNotificationController._internal();

  OverlayEntry? _currentEntry;
  bool _isShowing = false;

  void show({
    required String title,
    required String body,
    String? imageUrl,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (_isShowing) {
      // Replace current banner
      _removeEntry();
    }

    final navigatorState = NavigationService.navigatorKey.currentState;
    if (navigatorState == null) return;

    final GlobalKey bannerKey = GlobalKey();

    _currentEntry = OverlayEntry(
      builder: (_) {
        return IgnorePointer(
          ignoring: false,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: InAppNotificationBanner(
                  key: bannerKey,
                  title: title,
                  body: body,
                  imageUrl: imageUrl,
                  onTap: () {
                    onTap?.call();
                    // Let the banner handle its own smooth dismiss
                    // Actual removal will happen in onDismissed callback
                  },
                  onDismissed: () => hide(),
                ),
              ),
            ],
          ),
        );
      },
    );

    final overlay = navigatorState.overlay;
    if (overlay == null) return;
    overlay.insert(_currentEntry!);
    _isShowing = true;

    Future.delayed(duration, () {
      final state = bannerKey.currentState;
      if (state != null) {
        try {
          // Call the state's public dismiss method via dynamic to avoid private type coupling
          (state as dynamic).dismissSmoothly();
        } catch (_) {
          hide();
        }
      } else {
        hide();
      }
    });
  }

  void hide() {
    _removeEntry();
  }

  void _removeEntry() {
    _currentEntry?.remove();
    _currentEntry = null;
    _isShowing = false;
  }
}