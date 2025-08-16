import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/universal_chat_page.dart';

class StoreReceiverChatPage extends StatelessWidget {
  final User customer;
  final String? productId;

  const StoreReceiverChatPage({
    super.key,
    required this.customer,
    this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalChatPage(
      otherUser: customer,
      chatType: ChatType.storeReceiver,
      themeColor: Colors.purple,
    );
  }
}
