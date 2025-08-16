import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/service_ad.dart';
import '../widgets/universal_chat_page.dart';

class ServiceAdChatPage extends StatelessWidget {
  final User providerUser;
  final ServiceAd serviceAd;

  const ServiceAdChatPage({
    super.key,
    required this.providerUser,
    required this.serviceAd,
  });

  @override
  Widget build(BuildContext context) {
    final serviceColor = serviceAd.serviceType == ServiceAdType.training ? Colors.blue : Colors.green;
    
    return UniversalChatPage(
      otherUser: providerUser,
      chatType: ChatType.serviceAd,
      themeColor: serviceColor,
      initialServiceAd: serviceAd,
    );
  }
}