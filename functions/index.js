const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Send push notification to specific user
exports.sendNotification = functions.https.onCall(async (data, context) => {
  try {
    const { token, title, body, data: notificationData } = data;

    if (!token || !title || !body) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
    }

    const message = {
      token: token,
      notification: {
        title: title,
        body: body,
      },
      data: notificationData || {},
      android: {
        notification: {
          channelId: 'alifi_notifications',
          priority: 'high',
          defaultSound: true,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    
    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error sending notification:', error);
    throw new functions.https.HttpsError('internal', 'Error sending notification');
  }
});

// Send notification to multiple users
exports.sendNotificationToUsers = functions.https.onCall(async (data, context) => {
  try {
    const { userIds, title, body, data: notificationData } = data;

    if (!userIds || !Array.isArray(userIds) || !title || !body) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
    }

    // Get FCM tokens for all users
    const userDocs = await admin.firestore()
      .collection('users')
      .where(admin.firestore.FieldPath.documentId(), 'in', userIds)
      .get();

    const tokens = [];
    userDocs.forEach(doc => {
      const userData = doc.data();
      if (userData.fcmToken) {
        tokens.push(userData.fcmToken);
      }
    });

    if (tokens.length === 0) {
      return { success: true, message: 'No valid tokens found' };
    }

    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: notificationData || {},
      android: {
        notification: {
          channelId: 'alifi_notifications',
          priority: 'high',
          defaultSound: true,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
      tokens: tokens,
    };

    const response = await admin.messaging().sendMulticast(message);
    console.log('Successfully sent messages:', response);
    
    return { 
      success: true, 
      successCount: response.successCount,
      failureCount: response.failureCount,
    };
  } catch (error) {
    console.error('Error sending notifications:', error);
    throw new functions.https.HttpsError('internal', 'Error sending notifications');
  }
});

// Trigger notification when new chat message is created
exports.onChatMessageCreated = functions.firestore
  .document('chatMessages/{messageId}')
  .onCreate(async (snap, context) => {
    try {
      const messageData = snap.data();
      const { senderId, receiverId, message } = messageData;

      // Get sender info
      const senderDoc = await admin.firestore().collection('users').doc(senderId).get();
      const senderData = senderDoc.data();

      // Get receiver's FCM token
      const receiverDoc = await admin.firestore().collection('users').doc(receiverId).get();
      const receiverData = receiverDoc.data();

      if (!receiverData?.fcmToken) {
        console.log('No FCM token found for receiver');
        return;
      }

      const notificationMessage = {
        token: receiverData.fcmToken,
        notification: {
          title: 'New Message',
          body: message.length > 50 ? `${message.substring(0, 50)}...` : message,
        },
        data: {
          type: 'chatMessage',
          senderId: senderId,
          senderName: senderData?.displayName || 'User',
          message: message,
        },
        android: {
          notification: {
            channelId: 'alifi_notifications',
            priority: 'high',
            defaultSound: true,
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(notificationMessage);
      console.log('Successfully sent chat notification:', response);
    } catch (error) {
      console.error('Error sending chat notification:', error);
    }
  });

// Trigger notification when new order is created
exports.onOrderCreated = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    try {
      const orderData = snap.data();
      const { storeId, customerId, productName } = orderData;

      // Get customer info
      const customerDoc = await admin.firestore().collection('users').doc(customerId).get();
      const customerData = customerDoc.data();

      // Get store's FCM token
      const storeDoc = await admin.firestore().collection('users').doc(storeId).get();
      const storeData = storeDoc.data();

      if (!storeData?.fcmToken) {
        console.log('No FCM token found for store');
        return;
      }

      const notificationMessage = {
        token: storeData.fcmToken,
        notification: {
          title: 'New Order Received',
          body: `You received a new order for ${productName}`,
        },
        data: {
          type: 'orderPlaced',
          customerId: customerId,
          customerName: customerData?.displayName || 'Customer',
          productName: productName,
          orderId: context.params.orderId,
        },
        android: {
          notification: {
            channelId: 'alifi_notifications',
            priority: 'high',
            defaultSound: true,
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(notificationMessage);
      console.log('Successfully sent order notification:', response);
    } catch (error) {
      console.error('Error sending order notification:', error);
    }
  });

// Trigger notification when order status is updated
exports.onOrderStatusUpdated = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    try {
      const beforeData = change.before.data();
      const afterData = change.after.data();
      
      // Only trigger if status changed
      if (beforeData.status === afterData.status) {
        return;
      }

      const { storeId, customerId, productName, status } = afterData;

      // Get store info
      const storeDoc = await admin.firestore().collection('users').doc(storeId).get();
      const storeData = storeDoc.data();

      // Get customer's FCM token
      const customerDoc = await admin.firestore().collection('users').doc(customerId).get();
      const customerData = customerDoc.data();

      if (!customerData?.fcmToken) {
        console.log('No FCM token found for customer');
        return;
      }

      let title, body;
      switch (status) {
        case 'confirmed':
          title = 'Order Confirmed';
          body = `Your order for ${productName} has been confirmed`;
          break;
        case 'shipped':
          title = 'Order Shipped';
          body = `Your order for ${productName} has been shipped`;
          break;
        case 'delivered':
          title = 'Order Delivered';
          body = `Your order for ${productName} has been delivered`;
          break;
        case 'cancelled':
          title = 'Order Cancelled';
          body = `Your order for ${productName} has been cancelled`;
          break;
        default:
          return; // Don't send notification for other statuses
      }

      const notificationMessage = {
        token: customerData.fcmToken,
        notification: {
          title: title,
          body: body,
        },
        data: {
          type: status,
          storeId: storeId,
          storeName: storeData?.displayName || 'Store',
          productName: productName,
          orderId: context.params.orderId,
        },
        android: {
          notification: {
            channelId: 'alifi_notifications',
            priority: 'high',
            defaultSound: true,
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(notificationMessage);
      console.log('Successfully sent order status notification:', response);
    } catch (error) {
      console.error('Error sending order status notification:', error);
    }
  }); 