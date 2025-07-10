import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDK5PPrAoHfW-Q25xSle6u83CDPzbMq_lM',
    appId: '1:261633708467:web:dc6f5038b839dd87497bc6',
    messagingSenderId: '261633708467',
    projectId: 'alifi-924c1',
    authDomain: 'alifi-924c1.firebaseapp.com',
    storageBucket: 'alifi-924c1.firebasestorage.app',
    measurementId: 'G-YY5T2PT4DQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',  // Keep this for now, we'll update it with Android values
    appId: 'your-android-app-id',
    messagingSenderId: '261633708467',
    projectId: 'alifi-924c1',
    storageBucket: 'alifi-924c1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',  // Keep this for now, we'll update it with iOS values
    appId: 'your-ios-app-id',
    messagingSenderId: '261633708467',
    projectId: 'alifi-924c1',
    storageBucket: 'alifi-924c1.firebasestorage.app',
    iosClientId: 'your-ios-client-id',
    iosBundleId: 'com.example.alifi',
  );
} 