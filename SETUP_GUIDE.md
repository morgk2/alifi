# Setup and Deployment Guide - Alifi Pet Care App

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Firebase Configuration](#firebase-configuration)
4. [Supabase Configuration](#supabase-configuration)
5. [Google APIs Setup](#google-apis-setup)
6. [Local Development](#local-development)
7. [Testing](#testing)
8. [Building for Production](#building-for-production)
9. [Deployment](#deployment)
10. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software
- **Flutter SDK** (3.2.6 or higher)
- **Dart SDK** (3.0.0 or higher)
- **Android Studio** or **VS Code**
- **Git**
- **Node.js** (for Firebase CLI)

### Required Accounts
- **Google Cloud Console** account
- **Firebase** project
- **Supabase** project
- **Apple Developer** account (for iOS deployment)
- **Google Play Console** account (for Android deployment)

### System Requirements
- **Operating System**: Windows 10+, macOS 10.15+, or Ubuntu 18.04+
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 10GB free space
- **Internet**: Stable connection for package downloads

## Environment Setup

### 1. Install Flutter SDK

**Windows:**
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\flutter
# Add C:\flutter\bin to PATH environment variable
```

**macOS:**
```bash
# Using Homebrew
brew install flutter

# Or manual installation
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"
```

**Linux:**
```bash
# Download and extract Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.5-stable.tar.xz
tar xf flutter_linux_3.16.5-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. Verify Flutter Installation
```bash
flutter doctor
```

**Expected Output:**
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.16.5, on Microsoft Windows [Version 10.0.19045.3693], locale en-US)
[✓] Windows Version (Installed version of Windows is version 10 or higher)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Chrome - develop for the web (version 120.0.6099.109)
[✓] Visual Studio - develop for Windows (Visual Studio Community 2022 17.8.34330.188)
[✓] Android Studio (version 2023.1.1)
[✓] VS Code (version 1.85.1)
[✓] Connected device (3 available)
[✓] Network resources

• No issues found!
```

### 3. Install Dependencies
```bash
# Clone the repository
git clone https://github.com/your-username/alifi-pet-care-app.git
cd alifi-pet-care-app

# Install Flutter dependencies
flutter pub get

# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login
```

## Firebase Configuration

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "alifi-pet-care"
4. Enable Google Analytics (optional)
5. Click "Create project"

### 2. Enable Firebase Services

**Authentication:**
1. Go to Authentication > Sign-in method
2. Enable the following providers:
   - Google
   - Apple (iOS only)
   - Facebook
   - Email/Password

**Firestore Database:**
1. Go to Firestore Database
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select location closest to your users

**Storage:**
1. Go to Storage
2. Click "Get started"
3. Choose "Start in test mode"
4. Select location

**Cloud Messaging:**
1. Go to Cloud Messaging
2. Note the Server key for push notifications

### 3. Configure Firebase for Flutter

**Install FlutterFire CLI:**
```bash
dart pub global activate flutterfire_cli
```

**Configure Firebase:**
```bash
flutterfire configure --project=alifi-pet-care
```

**Update firebase_options.dart:**
```dart
// lib/firebase_options.dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-web-api-key',
    appId: 'your-web-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'alifi-pet-care',
    authDomain: 'alifi-pet-care.firebaseapp.com',
    storageBucket: 'alifi-pet-care.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'alifi-pet-care',
    storageBucket: 'alifi-pet-care.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'alifi-pet-care',
    storageBucket: 'alifi-pet-care.appspot.com',
    iosClientId: 'your-ios-client-id',
    iosBundleId: 'com.example.alifi',
  );
}
```

### 4. Set Up Firestore Security Rules

**Update firestore.rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read/write their own pets
    match /pets/{petId} {
      allow read, write: if request.auth != null && 
        resource.data.ownerId == request.auth.uid;
    }
    
    // Public read access for marketplace products
    match /storeproducts/{productId} {
      allow read: if true;
      allow write: if request.auth != null && 
        resource.data.sellerId == request.auth.uid;
    }
    
    // Chat messages
    match /chatMessages/{messageId} {
      allow read, write: if request.auth != null && 
        (resource.data.senderId == request.auth.uid || 
         resource.data.recipientId == request.auth.uid);
    }
  }
}
```

## Supabase Configuration

### 1. Create Supabase Project
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Click "New project"
3. Enter project name: "alifi-storage"
4. Set database password
5. Choose region
6. Click "Create new project"

### 2. Configure Storage Buckets
1. Go to Storage > Buckets
2. Create the following buckets:
   - `pet-images` (for pet photos)
   - `product-images` (for marketplace products)
   - `user-avatars` (for user profile pictures)

### 3. Set Storage Policies

**Update supabase_storage_policies.sql:**
```sql
-- Allow authenticated users to upload pet images
CREATE POLICY "Users can upload pet images" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'pet-images' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow public read access to pet images
CREATE POLICY "Public read access to pet images" ON storage.objects
FOR SELECT USING (bucket_id = 'pet-images');

-- Allow users to update their own pet images
CREATE POLICY "Users can update their pet images" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'pet-images' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to delete their own pet images
CREATE POLICY "Users can delete their pet images" ON storage.objects
FOR DELETE USING (
  bucket_id = 'pet-images' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);
```

### 4. Update Supabase Configuration

**Update config/supabase_config.dart:**
```dart
class SupabaseConfig {
  static const String projectUrl = 'https://your-project-id.supabase.co';
  static const String anonKey = 'your-anon-key';
}
```

## Google APIs Setup

### 1. Google Cloud Console Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable the following APIs:
   - Google Maps JavaScript API
   - Places API
   - Geocoding API
   - Google Generative AI API

### 2. Create API Keys
1. Go to APIs & Services > Credentials
2. Click "Create credentials" > "API key"
3. Create separate keys for:
   - Maps API
   - Places API
   - Gemini AI API

### 3. Configure API Keys

**Update Android Configuration:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest ...>
  <application ...>
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="your-maps-api-key"/>
  </application>
</manifest>
```

**Update iOS Configuration:**
```xml
<!-- ios/Runner/Info.plist -->
<key>GMSApiKey</key>
<string>your-maps-api-key</string>
```

**Update Web Configuration:**
```html
<!-- web/index.html -->
<script>
  window.googleMapsApiKey = 'your-maps-api-key';
</script>
```

### 4. Update API Keys in Code

**Update services/places_service.dart:**
```dart
class PlacesService {
  static const String _apiKey = 'your-places-api-key';
  // ... rest of the service
}
```

**Update widgets/ai_assistant_card.dart:**
```dart
class _AIPetAssistantCardState extends State<AIPetAssistantCard> {
  static const String _apiKey = 'your-gemini-api-key';
  // ... rest of the widget
}
```

## Local Development

### 1. Environment Variables
Create `.env` file in project root:
```env
# Firebase
FIREBASE_PROJECT_ID=alifi-pet-care
FIREBASE_WEB_API_KEY=your-web-api-key
FIREBASE_ANDROID_API_KEY=your-android-api-key
FIREBASE_IOS_API_KEY=your-ios-api-key

# Supabase
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Google APIs
GOOGLE_MAPS_API_KEY=your-maps-api-key
GOOGLE_PLACES_API_KEY=your-places-api-key
GOOGLE_GEMINI_API_KEY=your-gemini-api-key

# Other Services
STRIPE_PUBLISHABLE_KEY=your-stripe-key
PAYPAL_CLIENT_ID=your-paypal-client-id
```

### 2. Run the App
```bash
# Check for connected devices
flutter devices

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Run on web
flutter run -d chrome

# Run on Windows
flutter run -d windows
```

### 3. Hot Reload
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

### 4. Debug Mode
```bash
# Run in debug mode with verbose logging
flutter run --debug --verbose

# Run with specific flavor
flutter run --flavor development
```

## Testing

### 1. Unit Tests
```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/services/auth_service_test.dart

# Run tests with coverage
flutter test --coverage
```

### 2. Widget Tests
```bash
# Run widget tests
flutter test test/widget_test.dart

# Run integration tests
flutter test integration_test/
```

### 3. Manual Testing Checklist
- [ ] Authentication (Google, Apple, Facebook, Email)
- [ ] Pet management (CRUD operations)
- [ ] Marketplace functionality
- [ ] AI assistant chat
- [ ] Location services
- [ ] Push notifications
- [ ] Image upload/download
- [ ] Payment processing
- [ ] Multi-language support

## Building for Production

### 1. Android Build
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Build with specific flavor
flutter build apk --release --flavor production
```

### 2. iOS Build
```bash
# Build for iOS
flutter build ios --release

# Archive for App Store
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release archive -archivePath build/Runner.xcarchive
```

### 3. Web Build
```bash
# Build for web
flutter build web --release

# Build with specific base href
flutter build web --release --base-href "/alifi/"
```

### 4. Windows Build
```bash
# Build for Windows
flutter build windows --release
```

## Deployment

### 1. Android Deployment (Google Play Store)

**Prepare Release:**
1. Update `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        applicationId "com.example.alifi"
        versionCode 1
        versionName "1.0.0"
    }
}
```

2. Generate signed APK:
```bash
# Create keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Configure signing
# Update android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<location of the keystore file>
```

3. Upload to Play Console:
- Go to [Google Play Console](https://play.google.com/console)
- Create new app
- Upload APK/AAB
- Fill in store listing
- Submit for review

### 2. iOS Deployment (App Store)

**Prepare Release:**
1. Update `ios/Runner/Info.plist`:
```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

2. Archive and upload:
- Open Xcode
- Select "Any iOS Device" as target
- Product > Archive
- Upload to App Store Connect

3. Submit for review:
- Go to [App Store Connect](https://appstoreconnect.apple.com/)
- Create new app
- Upload build
- Submit for review

### 3. Web Deployment

**Firebase Hosting:**
```bash
# Initialize Firebase hosting
firebase init hosting

# Build and deploy
flutter build web --release
firebase deploy --only hosting
```

**Netlify:**
1. Connect GitHub repository
2. Set build command: `flutter build web --release`
3. Set publish directory: `build/web`
4. Deploy automatically

**Vercel:**
1. Import GitHub repository
2. Set build command: `flutter build web --release`
3. Set output directory: `build/web`
4. Deploy

### 4. Windows Deployment

**Microsoft Store:**
1. Create app in [Partner Center](https://partner.microsoft.com/)
2. Package app using MSIX
3. Upload and submit for review

**Direct Distribution:**
```bash
# Build installer
flutter build windows --release
# Use tools like Inno Setup or NSIS to create installer
```

## Troubleshooting

### Common Issues

**1. Flutter Doctor Issues:**
```bash
# Update Flutter
flutter upgrade

# Clean and get packages
flutter clean
flutter pub get

# Check for issues
flutter doctor -v
```

**2. Firebase Issues:**
```bash
# Reconfigure Firebase
flutterfire configure

# Check Firebase CLI
firebase --version
firebase projects:list
```

**3. Build Issues:**
```bash
# Clean build
flutter clean
flutter pub get
flutter build apk --release

# Check for errors
flutter analyze
```

**4. iOS Build Issues:**
```bash
# Update CocoaPods
cd ios
pod repo update
pod install
cd ..

# Clean iOS build
flutter clean
flutter pub get
```

**5. Android Build Issues:**
```bash
# Update Gradle
cd android
./gradlew clean
./gradlew build
cd ..

# Check Android SDK
flutter doctor --android-licenses
```

### Performance Optimization

**1. Image Optimization:**
```dart
// Use cached network images
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

**2. Memory Management:**
```dart
// Dispose controllers properly
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

**3. State Management:**
```dart
// Use ValueNotifier for local state
final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
```

### Security Best Practices

**1. API Key Security:**
- Never commit API keys to version control
- Use environment variables
- Implement key rotation

**2. Data Validation:**
```dart
// Validate user input
if (email.isEmpty || !email.contains('@')) {
  throw ArgumentError('Invalid email address');
}
```

**3. Authentication:**
- Implement proper session management
- Use secure token storage
- Validate user permissions

### Monitoring and Analytics

**1. Firebase Analytics:**
```dart
// Track user events
await FirebaseAnalytics.instance.logEvent(
  name: 'pet_added',
  parameters: {
    'pet_species': 'dog',
    'pet_breed': 'golden_retriever',
  },
);
```

**2. Crash Reporting:**
```dart
// Report errors
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'User action failed',
);
```

**3. Performance Monitoring:**
```dart
// Monitor app performance
FirebasePerformance.instance.newTrace('pet_creation').start();
// ... perform operation
trace.stop();
```

This comprehensive setup guide provides all the necessary steps to configure, develop, test, and deploy the Alifi pet care app across multiple platforms.