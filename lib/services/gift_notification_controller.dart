import 'dart:async';
import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../services/database_service.dart';
import '../dialogs/gift_received_dialog.dart';
import 'auth_service.dart';

class GiftNotificationController {
  final BuildContext context;
  final AuthService authService;
  StreamSubscription<List<Gift>>? _receivedGiftsSubscription;
  StreamSubscription<List<Gift>>? _sentGiftsSubscription;
  final Map<String, String> _processedGifts = {};

  GiftNotificationController(this.context, this.authService) {
    _init();
  }

  void _init() {
    authService.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
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
            builder: (context) => GiftReceivedDialog(gift: gift),
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

          if (gift.status == 'accepted' || gift.status == 'rejected') {
            _processedGifts[gift.id] = gift.status;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Your gift to ${gift.gifteeId} was ${gift.status}.',
                ),
                backgroundColor:
                    gift.status == 'accepted' ? Colors.green : Colors.red,
              ),
            );
          }
        }
      });
    } else {
      _receivedGiftsSubscription?.cancel();
      _sentGiftsSubscription?.cancel();
    }
  }

  void dispose() {
    authService.removeListener(_onAuthStateChanged);
    _receivedGiftsSubscription?.cancel();
    _sentGiftsSubscription?.cancel();
  }
} 