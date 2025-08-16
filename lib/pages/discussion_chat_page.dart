import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/universal_chat_page.dart';

class DiscussionChatPage extends StatelessWidget {
  final User storeUser;

  const DiscussionChatPage({
    super.key,
    required this.storeUser,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalChatPage(
      otherUser: storeUser,
      chatType: ChatType.discussion,
      themeColor: Colors.blue,
    );
  }
}
