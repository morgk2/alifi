import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { create, verify } from "https://deno.land/x/djwt@v2.8/mod.ts"

serve(async (req) => {
  try {
    const { token, title, body, data, type } = await req.json()

    if (!token || !title || !body) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: token, title, body' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

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
      return new Response(
        JSON.stringify({ 
          error: 'Firebase service account not configured',
          details: 'Missing required environment variables: FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, or FIREBASE_PRIVATE_KEY'
        }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      )
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
    
    console.log('🔍 [DEBUG] Service account created, project_id:', serviceAccount.project_id)

    // Get access token for Firebase
    console.log('🔍 [DEBUG] Getting Firebase access token...')
    const accessToken = await getFirebaseAccessToken(serviceAccount)
    console.log('✅ [DEBUG] Firebase access token obtained successfully')

    // Send FCM message using Firebase REST API
    console.log('🔍 [DEBUG] Sending FCM message...')
    const fcmResponse = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token: token,
            notification: {
              title: title,
              body: body,
            },
            data: {
              click_action: 'FLUTTER_NOTIFICATION_CLICK',
              type: type || 'general',
              ...(data || {}),
            },
            android: {
              notification: {
                channelId: 'alifi_notifications',
                defaultSound: true,
                defaultVibrateTimings: true,
                icon: 'ic_notification',
                color: '#2196F3',
                image: data?.senderPhotoUrl || data?.imageUrl,
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
                  'mutable-content': 1, // Enable rich notifications
                },
              },
              fcm_options: {
                image: data?.senderPhotoUrl || data?.imageUrl,
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
          },
        }),
      }
    )

    if (!fcmResponse.ok) {
      const errorText = await fcmResponse.text()
      console.error('❌ [DEBUG] FCM API error:', errorText)
      return new Response(
        JSON.stringify({ 
          error: 'Failed to send notification via FCM API',
          details: errorText,
          statusCode: fcmResponse.status
        }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      )
    }

    const result = await fcmResponse.json()
    console.log('✅ [DEBUG] FCM message sent successfully:', result.name)
    
    return new Response(
      JSON.stringify({ 
        success: true, 
        messageId: result.name 
      }),
      { headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ [DEBUG] Error sending notification:', error)
    return new Response(
      JSON.stringify({ 
        error: 'Failed to send notification',
        details: error.message 
      }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})

// New endpoint for chat message notifications
Deno.serve(async (req) => {
  if (req.method === 'POST') {
    try {
      const { recipientId, senderId, senderName, message } = await req.json();
      
      console.log('🔔 [ChatNotification] Received chat notification request');
      console.log('🔔 [ChatNotification] Recipient:', recipientId);
      console.log('🔔 [ChatNotification] Sender:', senderId, senderName);
      console.log('🔔 [ChatNotification] Message:', message);
      
      if (!recipientId || !senderId || !message) {
        return new Response(
          JSON.stringify({ 
            error: 'Missing required fields: recipientId, senderId, message' 
          }),
          { status: 400, headers: { 'Content-Type': 'application/json' } }
        );
      }
      
      // Get recipient's FCM token from Firestore
      const { createClient } = await import('https://esm.sh/@supabase/supabase-js@2');
      
      const supabaseUrl = Deno.env.get('SUPABASE_URL') || 'https://slkygguxwqzwpnahnici.supabase.co';
      const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
      
      if (!supabaseServiceKey) {
        return new Response(
          JSON.stringify({ error: 'Supabase service key not configured' }),
          { status: 500, headers: { 'Content-Type': 'application/json' } }
        );
      }
      
      const supabase = createClient(supabaseUrl, supabaseServiceKey);
      
      // Get FCM token from Firestore (using Supabase's Firestore bridge)
      const { data: userData, error: userError } = await supabase
        .from('users')
        .select('fcmToken')
        .eq('id', recipientId)
        .single();
      
      if (userError || !userData?.fcmToken) {
        console.log('❌ [ChatNotification] No FCM token found for user:', recipientId);
        return new Response(
          JSON.stringify({ 
            error: 'No FCM token found for recipient',
            details: userError?.message 
          }),
          { status: 404, headers: { 'Content-Type': 'application/json' } }
        );
      }
      
      const fcmToken = userData.fcmToken;
      console.log('✅ [ChatNotification] Found FCM token:', fcmToken.substring(0, 20) + '...');
      
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
      );
      
      return new Response(
        JSON.stringify(result),
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      );
      
    } catch (error) {
      console.error('❌ [ChatNotification] Error:', error);
      return new Response(
        JSON.stringify({ 
          error: 'Failed to send chat notification',
          details: error.message 
        }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      );
    }
  }
  
  return new Response(
    JSON.stringify({ error: 'Method not allowed' }),
    { status: 405, headers: { 'Content-Type': 'application/json' } }
  );
});

// Function to get Firebase access token using service account
async function getFirebaseAccessToken(serviceAccount: any): Promise<string> {
  const now = Math.floor(Date.now() / 1000)
  
  // Create JWT payload
  const payload = {
    iss: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  }

  // Create JWT header
  const header = {
    alg: 'RS256',
    typ: 'JWT',
    kid: serviceAccount.private_key_id,
  }

  // Import the private key
  const privateKey = await crypto.subtle.importKey(
    'pkcs8',
    base64ToArrayBuffer(serviceAccount.private_key),
    {
      name: 'RSASSA-PKCS1-v1_5',
      hash: 'SHA-256',
    },
    false,
    ['sign']
  )

  // Create JWT token
  const jwt = await create(header, payload, privateKey)

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

  const tokenData = await tokenResponse.json()
  return tokenData.access_token
}

// Helper function to convert base64 to ArrayBuffer
function base64ToArrayBuffer(base64: string): ArrayBuffer {
  const binaryString = atob(base64.replace(/-----BEGIN PRIVATE KEY-----|-----END PRIVATE KEY-----|\s/g, ''))
  const bytes = new Uint8Array(binaryString.length)
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i)
  }
  return bytes.buffer
}
