# Supabase Notification Bridge Setup Guide

This guide explains how to set up the bridge between Firestore and Supabase to send push notifications based on Firestore data changes.

## Overview

The bridge consists of:
1. **Supabase Edge Functions** - Handle notification sending
2. **Flutter Bridge Service** - Monitor Firestore changes and trigger Supabase functions
3. **Firebase Admin SDK** - Used by Supabase functions to send FCM notifications

## Prerequisites

- Supabase project with Edge Functions enabled
- Firebase project with FCM configured
- Firebase Admin SDK service account key

## Step 1: Set Up Supabase Environment Variables

In your Supabase project dashboard, go to Settings > Edge Functions and add these environment variables:

```bash
FIREBASE_SERVICE_ACCOUNT={"type":"service_account","project_id":"your_project_id","private_key_id":"your_private_key_id","private_key":"your_private_key","client_email":"your_client_email","client_id":"your_client_id","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_x509_cert_url":"your_cert_url"}
```

## Step 2: Deploy Supabase Edge Functions

### Deploy the Push Notification Function

```bash
# Navigate to your Supabase functions directory
cd supabase/functions

# Deploy the send-push-notification function
supabase functions deploy send-push-notification

# Deploy the firestore-bridge function
supabase functions deploy firestore-bridge
```

## Step 3: Configure Flutter App

### Add Environment Variables

Create a `.env` file in your project root:

```bash
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Update pubspec.yaml

Add the http package if not already present:

```yaml
dependencies:
  http: ^1.1.0
```

## Step 4: Initialize the Bridge

The bridge is automatically initialized in `AppInitializationService`. Make sure your app calls:

```dart
await AppInitializationService().initialize();
```

## Step 5: Test the Setup

### Test Direct Notification

```dart
final bridge = AppInitializationService().notificationBridge;
if (bridge != null) {
  await bridge.sendDirectNotification(
    token: 'user_fcm_token',
    title: 'Test Notification',
    body: 'This is a test notification from Supabase',
    type: 'test',
  );
}
```

### Test Firestore Trigger

1. Create a new chat message in Firestore
2. The bridge should automatically trigger a notification
3. Check Supabase function logs for any errors

## How It Works

### 1. Firestore Data Changes
- The `SupabaseNotificationBridge` listens to Firestore collections
- When data changes, it triggers Supabase Edge Functions

### 2. Supabase Edge Functions
- `firestore-bridge` processes Firestore events
- `send-push-notification` sends FCM notifications

### 3. Notification Delivery
- FCM delivers notifications to user devices
- Your existing notification handling code processes them

## Supported Events

### Chat Messages
- New chat creation
- New message in existing chat

### Orders
- Order placement
- Order status updates (confirmed, shipped, delivered, cancelled)

### Appointments
- Appointment requests
- Appointment status updates

## Troubleshooting

### Common Issues

1. **Supabase Function Not Deployed**
   - Check function deployment status
   - Verify environment variables are set

2. **Firebase Service Account Issues**
   - Ensure service account has FCM permissions
   - Check private key format in environment variable

3. **FCM Token Issues**
   - Verify FCM tokens are stored in Firestore
   - Check token refresh logic

### Debug Logs

Enable debug mode to see detailed logs:

```dart
if (kDebugMode) {
  print('Bridge logs will appear here');
}
```

## Security Considerations

1. **Service Account Security**
   - Keep Firebase service account key secure
   - Use environment variables, never commit to code

2. **Function Access**
   - Supabase functions are public by default
   - Add authentication if needed

3. **Data Validation**
   - Validate all data in Supabase functions
   - Sanitize user inputs

## Performance Optimization

1. **Batch Notifications**
   - Use `sendNotificationToUsers` for multiple recipients
   - Avoid sending individual notifications in loops

2. **Error Handling**
   - Implement retry logic for failed notifications
   - Log errors for debugging

3. **Rate Limiting**
   - Be mindful of FCM rate limits
   - Implement queuing for high-volume scenarios

## Monitoring

### Supabase Function Logs
- Check function logs in Supabase dashboard
- Monitor function execution times

### FCM Delivery Reports
- Use FCM delivery reports to track success rates
- Monitor token validity

### Firestore Usage
- Monitor Firestore read/write operations
- Optimize queries to reduce costs

## Migration from Firebase Functions

If you're migrating from Firebase Functions:

1. **Gradual Migration**
   - Keep existing Firebase functions during transition
   - Test thoroughly before removing

2. **Data Consistency**
   - Ensure both systems handle the same events
   - Avoid duplicate notifications

3. **Rollback Plan**
   - Keep Firebase function code as backup
   - Monitor for any issues during migration

## Support

For issues or questions:
1. Check Supabase function logs
2. Verify Firebase service account permissions
3. Test with simple notification first
4. Review this documentation for common solutions



