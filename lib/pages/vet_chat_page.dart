import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/universal_chat_page.dart';

class VetChatPage extends StatelessWidget {
  final User vetUser;

  const VetChatPage({
    super.key,
    required this.vetUser,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalChatPage(
      otherUser: vetUser,
      chatType: ChatType.vetConsultation,
      themeColor: Colors.blue,
    );
  }
}
