import 'package:flutter/material.dart';
import '../services/push_notification_service.dart';
import '../services/auth_service.dart';

class NotificationTestWidget extends StatelessWidget {
  const NotificationTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔔 Notification Test',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test if notifications are working properly',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await PushNotificationService().sendSimpleTestNotification();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Test notification sent!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('❌ Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.notifications),
                        label: const Text('Local Test'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            // Test sending a message notification via Supabase
                            // Use current user's ID instead of 'test_user'
                            final authService = AuthService();
                            final currentUser = authService.currentUser;
                            
                            if (currentUser != null) {
                              await PushNotificationService().sendPushNotification(
                                recipientUserId: currentUser.id,
                                title: '🔔 Supabase Test',
                                body: 'This is a test message via Supabase!',
                                data: {'type': 'chat_message', 'sender': 'test_user'},
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Supabase notification sent!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('❌ No user logged in'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('❌ Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.notifications_active),
                        label: const Text('Supabase Test'),
                      ),
                    ),
                  ],
                ),
                                 const SizedBox(height: 8),
                 Row(
                   children: [
                     Expanded(
                       child: ElevatedButton.icon(
                         onPressed: () async {
                           try {
                             await PushNotificationService().testSupabaseFunction();
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(
                                 content: Text('🧪 Direct Supabase test completed - check console'),
                                 backgroundColor: Colors.blue,
                               ),
                             );
                           } catch (e) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: Text('❌ Error: $e'),
                                 backgroundColor: Colors.red,
                               ),
                             );
                           }
                         },
                         icon: const Icon(Icons.bug_report),
                         label: const Text('Debug Supabase'),
                       ),
                     ),
                     const SizedBox(width: 8),
                     Expanded(
                       child: ElevatedButton.icon(
                         onPressed: () async {
                           try {
                             final authService = AuthService();
                             await authService.signInAsGuest();
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(
                                 content: Text('✅ Signed in as guest'),
                                 backgroundColor: Colors.green,
                               ),
                             );
                           } catch (e) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: Text('❌ Sign in error: $e'),
                                 backgroundColor: Colors.red,
                               ),
                             );
                           }
                         },
                         icon: const Icon(Icons.person),
                         label: const Text('Sign In Guest'),
                       ),
                     ),
                   ],
                 ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
