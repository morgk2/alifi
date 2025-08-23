import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  try {
    const { event, data, collection, documentId } = await req.json()

    console.log(`Received event: ${event} for collection: ${collection}`)

    // Handle different Firestore events
    switch (event) {
      case 'document.created':
        await handleDocumentCreated(collection, documentId, data)
        break
      case 'document.updated':
        await handleDocumentUpdated(collection, documentId, data)
        break
      case 'document.deleted':
        await handleDocumentDeleted(collection, documentId, data)
        break
      default:
        console.log(`Unhandled event: ${event}`)
    }

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error in firestore bridge:', error)
    return new Response(
      JSON.stringify({ 
        error: 'Failed to process Firestore event',
        details: error.message 
      }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})

// Handle new chat messages
async function handleDocumentCreated(collection: string, documentId: string, data: any) {
  console.log(`Document created: ${collection}/${documentId}`)
  
  if (collection === 'chats' && data.messages) {
    // New chat message
    const message = data.messages[data.messages.length - 1]
    await sendChatNotification(message, data)
  } else if (collection === 'orders') {
    // New order
    await sendOrderNotification(data, 'orderPlaced')
  } else if (collection === 'appointments') {
    // New appointment
    await sendAppointmentNotification(data, 'appointmentRequest')
  }
}

// Handle document updates
async function handleDocumentUpdated(collection: string, documentId: string, data: any) {
  console.log(`Document updated: ${collection}/${documentId}`)
  
  if (collection === 'orders') {
    // Order status update
    const status = data.status
    if (status === 'confirmed') {
      await sendOrderNotification(data, 'orderConfirmed')
    } else if (status === 'shipped') {
      await sendOrderNotification(data, 'orderShipped')
    } else if (status === 'delivered') {
      await sendOrderNotification(data, 'orderDelivered')
    } else if (status === 'cancelled') {
      await sendOrderNotification(data, 'orderCancelled')
    }
  } else if (collection === 'appointments') {
    // Appointment status update
    const status = data.status
    if (status === 'confirmed') {
      await sendAppointmentNotification(data, 'appointmentUpdate')
    }
  }
}

// Handle document deletions
async function handleDocumentDeleted(collection: string, documentId: string, data: any) {
  console.log(`Document deleted: ${collection}/${documentId}`)
}

// Send chat notification
async function sendChatNotification(message: any, chatData: any) {
  try {
    console.log('Sending chat notification...')
    
    // For now, just log the notification
    // In a real implementation, you would:
    // 1. Get FCM tokens from your database
    // 2. Send notifications using the send-push-notification function
    
    const notificationData = {
      title: `New message from ${message.senderName || 'Someone'}`,
      body: message.content || 'Sent a message',
      data: {
        chatId: chatData.id,
        senderId: message.senderId,
        type: 'chat_message',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      }
    }
    
    console.log('Chat notification data:', notificationData)
    
    // TODO: Implement actual notification sending
    // await sendNotificationToUsers(recipientIds, notificationData)
    
  } catch (error) {
    console.error('Error sending chat notification:', error)
  }
}

// Send order notification
async function sendOrderNotification(orderData: any, type: string) {
  try {
    console.log(`Sending order notification: ${type}`)
    
    let title, body
    switch (type) {
      case 'orderPlaced':
        title = 'Order Placed'
        body = `Your order has been placed successfully`
        break
      case 'orderConfirmed':
        title = 'Order Confirmed'
        body = `Your order has been confirmed`
        break
      case 'orderShipped':
        title = 'Order Shipped'
        body = `Your order has been shipped`
        break
      case 'orderDelivered':
        title = 'Order Delivered'
        body = `Your order has been delivered`
        break
      case 'orderCancelled':
        title = 'Order Cancelled'
        body = `Your order has been cancelled`
        break
      default:
        title = 'Order Update'
        body = `Your order has been updated`
    }
    
    const notificationData = {
      title: title,
      body: body,
      data: {
        type: type,
        orderId: orderData.id,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      }
    }
    
    console.log('Order notification data:', notificationData)
    
    // TODO: Implement actual notification sending
    // await sendNotificationToUser(orderData.userId, notificationData)
    
  } catch (error) {
    console.error('Error sending order notification:', error)
  }
}

// Send appointment notification
async function sendAppointmentNotification(appointmentData: any, type: string) {
  try {
    console.log(`Sending appointment notification: ${type}`)
    
    let title, body
    switch (type) {
      case 'appointmentRequest':
        title = 'Appointment Request'
        body = `Your appointment request has been submitted`
        break
      case 'appointmentUpdate':
        title = 'Appointment Update'
        body = `Your appointment has been updated`
        break
      default:
        title = 'Appointment Update'
        body = `Your appointment has been updated`
    }
    
    const notificationData = {
      title: title,
      body: body,
      data: {
        type: type,
        appointmentId: appointmentData.id,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      }
    }
    
    console.log('Appointment notification data:', notificationData)
    
    // TODO: Implement actual notification sending
    // await sendNotificationToUser(appointmentData.userId, notificationData)
    
  } catch (error) {
    console.error('Error sending appointment notification:', error)
  }
}
