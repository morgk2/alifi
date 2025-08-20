import 'package:flutter/material.dart';
import '../models/store_product.dart';
import '../models/user.dart';
import '../widgets/universal_chat_page.dart';

class StoreChatPage extends StatelessWidget {
  final StoreProduct product;
  final User storeUser;

  const StoreChatPage({
    super.key,
    required this.product,
    required this.storeUser,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalChatPage(
      otherUser: storeUser,
      chatType: ChatType.storeProduct,
      themeColor: Colors.green,
      initialProduct: product,
    );
  }
}
