import 'dart:async';
import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../services/database_service.dart';
import '../dialogs/gift_received_dialog.dart';
import '../widgets/gift_notification_banner.dart';
import 'auth_service.dart';

class GiftNotificationController {
  final BuildContext context;
  final AuthService authService;
  StreamSubscription<List<Gift>>? _receivedGiftsSubscription;
  StreamSubscription<List<Gift>>? _sentGiftsSubscription;
  final Map<String, String> _processedGifts = {};
  OverlayEntry? _currentNotification;

  GiftNotificationController(this.context, this.authService) {
    _init();
  }

  void _init() {
    authService.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  Future<void> _markGiftAsRead(Gift gift) async {
    try {
      await DatabaseService().updateGiftIsRead(gift.id, true);
    } catch (e) {
      print('Error marking gift as read: $e');
    }
  }

  void _showNotificationBanner(Gift gift) {
    // Only show if isRead is false
    if (gift.isRead == true) {
      return;
    }

    // Mark as read in Firestore
    _markGiftAsRead(gift);

    // Remove any existing notification
    _currentNotification?.remove();
    
    _currentNotification = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: GiftNotificationBanner(
          gift: gift,
          onDismiss: () {
            _currentNotification?.remove();
            _currentNotification = null;
          },
        ),
      ),
    );

    Overlay.of(context).insert(_currentNotification!);
  }

  void _onAuthStateChanged() {
    final user = authService.currentUser;
    if (user != null) {
      _receivedGiftsSubscription?.cancel();
      _receivedGiftsSubscription =
          DatabaseService().getPendingGifts(user.id).listen((gifts) {
        if (gifts.isNotEmpty) {
          final gift = gifts.first;
          if (_processedGifts.containsKey(gift.id) &&
              _processedGifts[gift.id] == 'pending') {
            return;
          }
          _processedGifts[gift.id] = 'pending';
          showDialog(
            context: context,
            builder: (context) => GiftReceivedDialog(gift: gift.toFirestore()),
          );
        }
      });

      _sentGiftsSubscription?.cancel();
      _sentGiftsSubscription =
          DatabaseService().getSentGifts(user.id).listen((gifts) {
        for (final gift in gifts) {
          if (_processedGifts.containsKey(gift.id) &&
              _processedGifts[gift.id] == gift.status) {
            continue;
          }

          if ((gift.status == 'accepted' || gift.status == 'rejected') && gift.isRead == false) {
            _processedGifts[gift.id] = gift.status;
            _showNotificationBanner(gift);
          }
        }
      });
    } else {
      _receivedGiftsSubscription?.cancel();
      _sentGiftsSubscription?.cancel();
      _currentNotification?.remove();
      _currentNotification = null;
    }
  }

  void dispose() {
    authService.removeListener(_onAuthStateChanged);
    _receivedGiftsSubscription?.cancel();
    _sentGiftsSubscription?.cancel();
    _currentNotification?.remove();
  }
} 