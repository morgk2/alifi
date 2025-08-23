import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

// Function to get Firebase access token using service account
async function getFirebaseAccessToken() {
  try {
    // Get Firebase service account from individual environment variables
    console.log('🔍 [DEBUG] Getting Firebase credentials from environment variables...')
    
    const projectId = Deno.env.get('FIREBASE_PROJECT_ID')
    const clientEmail = Deno.env.get('FIREBASE_CLIENT_EMAIL')
    const privateKey = Deno.env.get('FIREBASE_PRIVATE_KEY')
    const privateKeyId = Deno.env.get('FIREBASE_PRIVATE_KEY_ID')
    const clientId = Deno.env.get('FIREBASE_CLIENT_ID')
    
    console.log('🔍 [DEBUG] Project ID exists:', !!projectId)
    console.log('🔍 [DEBUG] Client Email exists:', !!clientEmail)
    console.log('🔍 [DEBUG] Private Key exists:', !!privateKey)
    
    if (!projectId || !clientEmail || !privateKey) {
      throw new Error('Firebase service account not configured')
    }
    
    // Create service account object
    const serviceAccount = {
      type: 'service_account',
      project_id: projectId,
      private_key_id: privateKeyId,
      private_key: privateKey,
      client_email: clientEmail,
      client_id: clientId,
      auth_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_uri: 'https://oauth2.googleapis.com/token',
      auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
      client_x509_cert_url: `https://www.googleapis.com/robot/v1/metadata/x509/${encodeURIComponent(clientEmail)}`,
      universe_domain: 'googleapis.com'
    }
    
    // Create JWT token
    const header = {
      alg: 'RS256',
      typ: 'JWT'
    }
    
    const now = Math.floor(Date.now() / 1000)
    const payload = {
      iss: serviceAccount.client_email,
      sub: serviceAccount.client_email,
      aud: 'https://oauth2.googleapis.com/token',
      iat: now,
      exp: now + 3600,
      scope: 'https://www.googleapis.com/auth/firebase.messaging'
    }
    
    // Sign JWT (simplified - in production you'd use a proper JWT library)
    const jwt = await createJWT(header, payload, serviceAccount.private_key)
    
    // Exchange JWT for access token
    const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt,
      }),
    })
    
    if (!tokenResponse.ok) {
      throw new Error(`Failed to get access token: ${tokenResponse.statusText}`)
    }
    
    const tokenData = await tokenResponse.json()
    return tokenData.access_token
  } catch (error) {
    console.error('❌ [DEBUG] Error getting Firebase access token:', error)
    throw error
  }
}

// Simplified JWT creation (in production, use a proper JWT library)
async function createJWT(header: any, payload: any, privateKey: string) {
  const encoder = new TextEncoder()
  
  const headerB64 = btoa(JSON.stringify(header))
  const payloadB64 = btoa(JSON.stringify(payload))
  
  const data = `${headerB64}.${payloadB64}`
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    await importPrivateKey(privateKey),
    encoder.encode(data)
  )
  
  const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
  return `${data}.${signatureB64}`
}

// Import private key for signing
async function importPrivateKey(privateKeyPem: string) {
  const privateKey = privateKeyPem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s/g, '')
  
  const binaryKey = Uint8Array.from(atob(privateKey), c => c.charCodeAt(0))
  
  return await crypto.subtle.importKey(
    'pkcs8',
    binaryKey,
    {
      name: 'RSASSA-PKCS1-v1_5',
      hash: 'SHA-256',
    },
    false,
    ['sign']
  )
}

// Send notification to specific FCM token
async function sendNotificationToToken(token: string, title: string, body: string, data: any = {}) {
  try {
    const accessToken = await getFirebaseAccessToken()
    
    const message = {
      message: {
        token: token,
        notification: {
          title: title,
          body: body,
        },
        data: {
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          type: 'chatMessage',
          ...data,
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
      },
    }
    
    console.log('📱 [DEBUG] Sending FCM message:', JSON.stringify(message, null, 2))
    
    const response = await fetch(`https://fcm.googleapis.com/v1/projects/alifi-924c1/messages:send`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(message),
    })
    
    if (!response.ok) {
      const errorText = await response.text()
      console.error('❌ [DEBUG] FCM API error:', response.status, errorText)
      throw new Error(`FCM API error: ${response.status} - ${errorText}`)
    }
    
    const result = await response.json()
    console.log('✅ [DEBUG] FCM message sent successfully:', result)
    return result
  } catch (error) {
    console.error('❌ [DEBUG] Error sending FCM message:', error)
    throw error
  }
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    })
  }
  
  if (req.method === 'POST') {
    try {
      const { recipientId, senderId, senderName, message } = await req.json()
      
      console.log('🔔 [ChatNotification] Received chat notification request')
      console.log('🔔 [ChatNotification] Recipient:', recipientId)
      console.log('🔔 [ChatNotification] Sender:', senderId, senderName)
      console.log('🔔 [ChatNotification] Message:', message)
      
      if (!recipientId || !senderId || !message) {
        return new Response(
          JSON.stringify({ 
            error: 'Missing required fields: recipientId, senderId, message' 
          }),
          { 
            status: 400, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        )
      }
      
      // Get recipient's FCM token from Firestore
      console.log('🔍 [ChatNotification] Getting FCM token from Firestore...')
      
      // Use the same approach as the working send-push-notification function
      // Get FCM token from Firestore using HTTP request to Firestore REST API
      const firebaseProjectId = Deno.env.get('FIREBASE_PROJECT_ID')
      const accessToken = await getFirebaseAccessToken()
      
      // Get user document from Firestore
      const firestoreResponse = await fetch(
        `https://firestore.googleapis.com/v1/projects/${firebaseProjectId}/databases/(default)/documents/users/${recipientId}`,
        {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
          },
        }
      )
      
      if (!firestoreResponse.ok) {
        console.log('❌ [ChatNotification] Failed to get user from Firestore:', firestoreResponse.status)
        return new Response(
          JSON.stringify({ 
            error: 'Failed to get user from Firestore',
            details: `HTTP ${firestoreResponse.status}`
          }),
          { 
            status: 404, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        )
      }
      
      const userDoc = await firestoreResponse.json()
      
      if (!userDoc.fields) {
        console.log('❌ [ChatNotification] User not found in Firestore:', recipientId)
        return new Response(
          JSON.stringify({ 
            error: 'User not found in Firestore',
            details: 'User document does not exist'
          }),
          { 
            status: 404, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        )
      }
      
      // Extract FCM token from Firestore document
      const fcmToken = userDoc.fields.fcmToken?.stringValue
      
      if (!fcmToken) {
        console.log('❌ [ChatNotification] No FCM token found for user:', recipientId)
        return new Response(
          JSON.stringify({ 
            error: 'No FCM token found for recipient',
            details: 'User has no FCM token stored'
          }),
          { 
            status: 404, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        )
      }
      
      console.log('✅ [ChatNotification] Found FCM token:', fcmToken.substring(0, 20) + '...')
      
      // Send push notification
      const result = await sendNotificationToToken(
        fcmToken,
        `New message from ${senderName || 'Someone'}`,
        message.length > 50 ? message.substring(0, 50) + '...' : message,
        {
          type: 'chatMessage',
          senderId: senderId,
          senderName: senderName || 'Someone',
          message: message,
        }
      )
      
      return new Response(
        JSON.stringify(result),
        { 
          status: 200, 
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          } 
        }
      )
      
    } catch (error) {
      console.error('❌ [ChatNotification] Error:', error)
      return new Response(
        JSON.stringify({ 
          error: 'Failed to send chat notification',
          details: error.message 
        }),
        { 
          status: 500, 
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          } 
        }
      )
    }
  }
  
  return new Response(
    JSON.stringify({ error: 'Method not allowed' }),
    { 
      status: 405, 
      headers: { 
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      } 
    }
  )
})
