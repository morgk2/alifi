const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Send push notification function
exports.sendNotification = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'The function must be called while authenticated.'
    );
  }

  const { token, title, body, data: notificationData, type } = data;

  // Validate required fields
  if (!token || !title || !body) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required fields: token, title, body'
    );
  }

  try {
    const message = {
      token: token,
      notification: {
        title: title,
        body: body,
      },
      data: {
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        type: type || 'general',
        ...(notificationData || {}),
      },
      android: {
        notification: {
          channelId: 'alifi_notifications',
          priority: 'high',
          defaultSound: true,
          defaultVibrateTimings: true,
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
            },
            badge: 1,
            sound: 'default',
          },
        },
      },
      webpush: {
        notification: {
          title: title,
          body: body,
          icon: '/icons/Icon-192.png',
          badge: '/icons/Icon-192.png',
        },
      },
    };

    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    
    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error sending message:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to send notification',
      error
    );
  }
});

// Send notification to multiple devices
exports.sendNotificationToUsers = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'The function must be called while authenticated.'
    );
  }

  const { userIds, title, body, data: notificationData, type } = data;

  if (!userIds || !Array.isArray(userIds) || !title || !body) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required fields: userIds (array), title, body'
    );
  }

  try {
    // Get FCM tokens for all users
    const userTokens = [];
    
    for (const userId of userIds) {
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(userId)
        .get();
      
      if (userDoc.exists) {
        const userData = userDoc.data();
        if (userData.fcmToken) {
          userTokens.push(userData.fcmToken);
        }
      }
    }

    if (userTokens.length === 0) {
      return { success: true, message: 'No valid FCM tokens found' };
    }

    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        type: type || 'general',
        ...(notificationData || {}),
      },
      android: {
        notification: {
          channelId: 'alifi_notifications',
          priority: 'high',
          defaultSound: true,
          defaultVibrateTimings: true,
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
            },
            badge: 1,
            sound: 'default',
          },
        },
      },
      webpush: {
        notification: {
          title: title,
          body: body,
          icon: '/icons/Icon-192.png',
          badge: '/icons/Icon-192.png',
        },
      },
      tokens: userTokens,
    };

    const response = await admin.messaging().sendMulticast(message);
    console.log('Successfully sent multicast message:', response);
    
    return { 
      success: true, 
      successCount: response.successCount,
      failureCount: response.failureCount,
      responses: response.responses 
    };
  } catch (error) {
    console.error('Error sending multicast message:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to send notifications',
      error
    );
  }
});

// Background function to handle new chat messages
exports.onNewChatMessage = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const messageData = snap.data();
    const chatId = context.params.chatId;
    
    try {
      // Get chat participants
      const chatDoc = await admin.firestore()
        .collection('chats')
        .doc(chatId)
        .get();
      
      if (!chatDoc.exists) return;
      
      const chatData = chatDoc.data();
      const participants = chatData.participants || [];
      const senderId = messageData.senderId;
      
      // Get sender info
      const senderDoc = await admin.firestore()
        .collection('users')
        .doc(senderId)
        .get();
      
      const senderName = senderDoc.exists ? 
        (senderDoc.data().displayName || 'Someone') : 'Someone';
      
      // Send notification to all participants except sender
      const recipientIds = participants.filter(id => id !== senderId);
      
      if (recipientIds.length > 0) {
        await admin.messaging().sendMulticast({
          tokens: await getTokensForUsers(recipientIds),
          notification: {
            title: `New message from ${senderName}`,
            body: messageData.content || 'Sent a message',
          },
          data: {
            chatId: chatId,
            senderId: senderId,
            type: 'chat_message',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
        });
      }
    } catch (error) {
      console.error('Error sending chat notification:', error);
    }
  });

// Background function to handle new chat messages from chatMessages collection
exports.onNewChatMessageFromCollection = functions.firestore
  .document('chatMessages/{messageId}')
  .onCreate(async (snap, context) => {
    const messageData = snap.data();
    const messageId = context.params.messageId;
    
    try {
      console.log('New chat message received:', messageId);
      console.log('Message data:', messageData);
      
      const senderId = messageData.senderId;
      const receiverId = messageData.receiverId;
      const messageText = messageData.message || '';
      
      if (!senderId || !receiverId) {
        console.log('Missing senderId or receiverId, skipping notification');
        return;
      }
      
      // Get sender info
      const senderDoc = await admin.firestore()
        .collection('users')
        .doc(senderId)
        .get();
      
      const senderName = senderDoc.exists ? 
        (senderDoc.data().displayName || 'Someone') : 'Someone';
      
      // Get receiver's FCM token
      const receiverDoc = await admin.firestore()
        .collection('users')
        .doc(receiverId)
        .get();
      
      if (!receiverDoc.exists) {
        console.log('Receiver not found:', receiverId);
        return;
      }
      
      const receiverData = receiverDoc.data();
      const fcmToken = receiverData.fcmToken;
      
      if (!fcmToken) {
        console.log('No FCM token found for receiver:', receiverId);
        return;
      }
      
      console.log('Sending notification to:', receiverId);
      console.log('FCM token:', fcmToken.substring(0, 20) + '...');
      
      // Send push notification
      const message = {
        token: fcmToken,
        notification: {
          title: `New message from ${senderName}`,
          body: messageText.length > 50 ? messageText.substring(0, 50) + '...' : messageText,
        },
        data: {
          type: 'chatMessage',
          senderId: senderId,
          senderName: senderName,
          message: messageText,
          messageId: messageId,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          notification: {
            channelId: 'alifi_notifications',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title: `New message from ${senderName}`,
                body: messageText.length > 50 ? messageText.substring(0, 50) + '...' : messageText,
              },
              badge: 1,
              sound: 'default',
            },
          },
        },
      };
      
      const response = await admin.messaging().send(message);
      console.log('Successfully sent chat notification:', response);
      
    } catch (error) {
      console.error('Error sending chat notification:', error);
    }
  });

// Helper function to get FCM tokens for users
async function getTokensForUsers(userIds) {
  const tokens = [];
  
  for (const userId of userIds) {
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(userId)
      .get();
    
    if (userDoc.exists) {
      const userData = userDoc.data();
      if (userData.fcmToken) {
        tokens.push(userData.fcmToken);
      }
    }
  }
  
  return tokens;
}
