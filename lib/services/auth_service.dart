import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide OAuthProvider, User;
import '../models/user.dart' as models;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'local_storage_service.dart';
import 'database_service.dart';
import 'dart:math';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'push_notification_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '261633708467-uba68ge1mau5e89pf9ip7u55hb93l0p0.apps.googleusercontent.com' : null,
    scopes: [
      'email',
      'profile',
      if (kIsWeb) 'https://www.googleapis.com/auth/userinfo.email',
    ],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  final SupabaseClient _supabase = Supabase.instance.client;
  final PushNotificationService _pushNotificationService = PushNotificationService();
  models.User? _currentUser;
  SharedPreferences? _prefs;
  bool _initialized = false;
  bool _isGuestMode = false;
  bool _isLoadingUser = false;
  bool get isLoadingUser => _isLoadingUser;

  models.User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null || _isGuestMode;
  bool get isInitialized => _initialized;
  bool get isGuestMode => _isGuestMode;

  Future<void> _initializeSupabaseAuth() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        // Sign in anonymously to Supabase
        await _supabase.auth.signInAnonymously();
        print('Successfully authenticated with Supabase anonymously');
      }
    } catch (e) {
      print('Error initializing Supabase auth: $e');
    }
  }

  Future<void> init() async {
    if (_initialized) return;

    try {
      print('Starting AuthService initialization...');
      
      // Initialize SharedPreferences with timeout
      try {
        _prefs = await SharedPreferences.getInstance().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print('SharedPreferences initialization timed out');
            throw TimeoutException('SharedPreferences initialization timed out');
          },
        );
        print('SharedPreferences initialized');
        
        // Check if we were in guest mode
        _isGuestMode = await _localStorage.isGuestMode();
        if (_isGuestMode) {
          print('Restored guest mode');
          notifyListeners();
        }
      } catch (e) {
        print('Error initializing SharedPreferences: $e');
        // Continue without SharedPreferences
      }

      // Set up auth state listener
      _auth.authStateChanges().listen((firebaseUser) async {
        print('AuthService: Auth state changed - firebaseUser: ${firebaseUser?.email ?? 'null'}');
        if (firebaseUser == null) {
          print('AuthService: Firebase user is null, clearing current user');
          _currentUser = null;
          _isLoadingUser = false;
          await _prefs?.remove('user_id');
          // Sign out from Supabase as well
          await _supabase.auth.signOut();
          // Don't notify if in guest mode
          if (!_isGuestMode) {
            print('AuthService: Notifying listeners (user signed out)');
            notifyListeners();
          }
        } else {
          print('AuthService: Firebase user authenticated: ${firebaseUser.email}');
          _isLoadingUser = true;
          print('AuthService: Notifying listeners (loading user)');
          notifyListeners();

          // Initialize Supabase auth
          await _initializeSupabaseAuth();

          // Try to load from Firestore, but always set _currentUser at minimum
          try {
            print('AuthService: Loading user data from Firestore...');
            await _loadUserData(firebaseUser.uid);
            if (_currentUser == null) {
              print('AuthService: Firestore load failed, creating fallback user');
              // Fallback if Firestore fails
              _currentUser = models.User(
                id: firebaseUser.uid,
                email: firebaseUser.email ?? '',
                displayName: firebaseUser.displayName,
                photoURL: firebaseUser.photoURL,
                createdAt: DateTime.now(),
                lastLoginAt: DateTime.now(),
                linkedAccounts: {'google': true},
              );
              await _prefs?.setString('user_id', firebaseUser.uid);
            } else {
              print('AuthService: User data loaded successfully from Firestore');
            }
            
            // Update FCM token for the user
            await _updateFCMTokenForUser(firebaseUser.uid);
            
          } catch (e) {
            print('AuthService: Error loading user data: $e');
            // Fallback if anything fails
            _currentUser = models.User(
              id: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              displayName: firebaseUser.displayName,
              photoURL: firebaseUser.photoURL,
              createdAt: DateTime.now(),
              lastLoginAt: DateTime.now(),
              linkedAccounts: {'google': true},
            );
            await _prefs?.setString('user_id', firebaseUser.uid);
            
            // Still try to update FCM token
            await _updateFCMTokenForUser(firebaseUser.uid);
          }
          _isLoadingUser = false;
          print('AuthService: Notifying listeners (user loaded)');
          notifyListeners();
        }
      }, onError: (error) {
        print('AuthService: Error in auth state listener: $error');
        // Continue without auth state listener
      });

      // Check for cached user with timeout
      final cachedUserId = _prefs?.getString('user_id');
      if (cachedUserId != null) {
        try {
          await _loadUserData(cachedUserId).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('Loading cached user data timed out');
              throw TimeoutException('Loading cached user data timed out');
            },
          );
        } catch (e) {
          print('Error loading cached user data: $e');
          // Continue without cached user data
        }
      }

      if (kIsWeb) {
        // Initialize GoogleSignIn for web without silent sign-in
        print('Initialized GoogleSignIn for web platform');
      }
    } catch (e) {
      print('Error during AuthService initialization: $e');
    } finally {
      _initialized = true;
      notifyListeners();
      print('AuthService initialization completed');
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = models.User.fromFirestore(doc);
        await _prefs?.setString('user_id', uid);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _updateFCMTokenForUser(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _firestore
            .collection('users')
            .doc(uid)
            .update({
              'fcmToken': token,
              'lastTokenUpdate': FieldValue.serverTimestamp(),
            });
        print('FCM token updated for user $uid: $token');
      } else {
        print('FCM token is null for user $uid. No update needed.');
      }
    } catch (e) {
      print('Error updating FCM token for user $uid: $e');
    }
  }

  Future<models.User?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process...');
      GoogleSignInAccount? googleUser;
      
      if (kIsWeb) {
        print('Web platform detected, using web sign-in flow');
        try {
          // Force a new sign-in flow for web
          await _googleSignIn.signOut();
          googleUser = await _googleSignIn.signIn();
          print('Web Google Sign-In completed: ${googleUser?.email}');

          if (googleUser == null) {
            print('Web sign-in cancelled by user');
            return null;
          }

          // Get authentication details
          final googleAuth = await googleUser.authentication;
          print('Got Google authentication tokens');
          print('ID Token present: ${googleAuth.idToken != null}');
          print('Access Token present: ${googleAuth.accessToken != null}');

          // Create credential
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          // Sign in to Firebase
          final userCredential = await _auth.signInWithCredential(credential);
          final firebaseUser = userCredential.user;

          if (firebaseUser == null) {
            print('Firebase sign-in failed: null user');
            return null;
          }

          print('Firebase sign-in successful: ${firebaseUser.email}');

          // Check if user already exists and preserve their data
          final dbService = DatabaseService();
          final existingUser = await dbService.getUser(firebaseUser.uid);

          if (existingUser != null) {
            // Update only the authentication-related fields, preserve all other data
            final updatedUser = existingUser.copyWith(
              email: firebaseUser.email ?? existingUser.email,
              displayName: firebaseUser.displayName ?? existingUser.displayName,
              photoURL: firebaseUser.photoURL ?? existingUser.photoURL,
              lastLoginAt: DateTime.now(),
              linkedAccounts: {...existingUser.linkedAccounts, 'google': true},
              // Preserve all other fields
              isAdmin: existingUser.isAdmin,
              accountType: existingUser.accountType,
              username: existingUser.username,
              isVerified: existingUser.isVerified,
              basicInfo: existingUser.basicInfo,
              patients: existingUser.patients,
              rating: existingUser.rating,
              totalOrders: existingUser.totalOrders,
              pets: existingUser.pets,
              followers: existingUser.followers,
              following: existingUser.following,
              followersCount: existingUser.followersCount,
              followingCount: existingUser.followingCount,
              searchTokens: existingUser.searchTokens,
              products: existingUser.products,
            );
            await dbService.updateUser(updatedUser);
            print('Updated existing user data in Firestore, preserving all custom fields');
            return updatedUser;
          } else {
            // Create new user if doesn't exist
            final newUser = models.User(
              id: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              displayName: firebaseUser.displayName,
              photoURL: firebaseUser.photoURL,
              createdAt: DateTime.now(),
              lastLoginAt: DateTime.now(),
              linkedAccounts: {'google': true},
            );
            await dbService.createUser(newUser);
            print('Created new user in Firestore');
            return newUser;
          }
        } catch (e) {
          print('Error during web Google sign in: $e');
          rethrow;
        }
      } else {
        print('Mobile platform detected, using mobile sign-in flow');
        
        try {
          // First, ensure we're signed out
          await _googleSignIn.signOut();
          await _auth.signOut();
          print('Signed out of previous sessions');

          // Try interactive sign-in
          print('Starting interactive Google Sign-In...');
          googleUser = await _googleSignIn.signIn().timeout(
            const Duration(minutes: 1),
            onTimeout: () {
              print('Google Sign-In timed out');
              throw TimeoutException('Google Sign-In timed out');
            },
          );
          
          if (googleUser == null) {
            print('Interactive Google Sign-In cancelled by user');
            return null;
          }
          
          print('Interactive Google Sign-In successful: ${googleUser.email}');
          print('Server auth code: ${await googleUser.serverAuthCode}');
          print('ID token: ${(await googleUser.authentication).idToken != null}');
          print('Access token: ${(await googleUser.authentication).accessToken != null}');

          final googleAuth = await googleUser.authentication;
        print('Got Google authentication tokens');
        print('ID Token present: ${googleAuth.idToken != null}');
        print('Access Token present: ${googleAuth.accessToken != null}');

        if (googleAuth.accessToken == null || googleAuth.idToken == null) {
          print('Error: Missing authentication tokens');
          throw Exception('Failed to obtain authentication tokens');
        }

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken!,
          idToken: googleAuth.idToken!,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        final firebaseUser = userCredential.user;

        if (firebaseUser == null) {
          print('Firebase sign-in failed: null user');
          return null;
        }

        print('Firebase sign-in successful: ${firebaseUser.email}');

          // Check if user already exists and preserve their data
          final dbService = DatabaseService();
          final existingUser = await dbService.getUser(firebaseUser.uid);

          if (existingUser != null) {
            // Update only the authentication-related fields, preserve all other data
            final updatedUser = existingUser.copyWith(
              email: firebaseUser.email ?? existingUser.email,
              displayName: firebaseUser.displayName ?? existingUser.displayName,
              photoURL: firebaseUser.photoURL ?? existingUser.photoURL,
              lastLoginAt: DateTime.now(),
              linkedAccounts: {...existingUser.linkedAccounts, 'google': true},
              // Preserve all other fields
              isAdmin: existingUser.isAdmin,
              accountType: existingUser.accountType,
              username: existingUser.username,
              isVerified: existingUser.isVerified,
              basicInfo: existingUser.basicInfo,
              patients: existingUser.patients,
              rating: existingUser.rating,
              totalOrders: existingUser.totalOrders,
              pets: existingUser.pets,
              followers: existingUser.followers,
              following: existingUser.following,
              followersCount: existingUser.followersCount,
              followingCount: existingUser.followingCount,
              searchTokens: existingUser.searchTokens,
              products: existingUser.products,
            );
            await dbService.updateUser(updatedUser);
            print('Updated existing user data in Firestore, preserving all custom fields');
            return updatedUser;
          } else {
            // Create new user if doesn't exist
            final newUser = models.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          photoURL: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          linkedAccounts: {'google': true},
        );
            await dbService.createUser(newUser);
            print('Created new user in Firestore');
            return newUser;
          }
      } catch (e) {
          print('Error during mobile Google Sign-In: $e');
          if (e.toString().contains('network_error')) {
            throw Exception('Please check your internet connection');
          } else if (e.toString().contains('sign_in_failed')) {
            throw Exception('Google Sign-In failed. Please check Google Play Services');
          } else if (e.toString().contains('sign_in_canceled')) {
            return null;
          }
        rethrow;
        }
      }
    } catch (e) {
      print('Error in signInWithGoogle: $e');
      rethrow;
    }
  }

  Future<models.User?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return null;
      }

      final dbService = DatabaseService();
      final existingUser = await dbService.getUser(firebaseUser.uid);

      if (existingUser != null) {
        final updatedUser = existingUser.copyWith(
          email: firebaseUser.email ?? existingUser.email,
          displayName: firebaseUser.displayName ?? existingUser.displayName,
          photoURL: firebaseUser.photoURL ?? existingUser.photoURL,
          lastLoginAt: DateTime.now(),
          linkedAccounts: {...existingUser.linkedAccounts, 'apple': true},
        );
        await dbService.updateUser(updatedUser);
        return updatedUser;
      } else {
        final newUser = models.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          photoURL: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          linkedAccounts: {'apple': true},
        );
        await dbService.createUser(newUser);
        return newUser;
      }
    } catch (e) {
      print('Error in signInWithApple: $e');
      rethrow;
    }
  }

  Future<models.User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? firebaseUser = userCredential.user;

        if (firebaseUser == null) {
          return null;
        }

        final dbService = DatabaseService();
        final existingUser = await dbService.getUser(firebaseUser.uid);

        if (existingUser != null) {
          final updatedUser = existingUser.copyWith(
            email: firebaseUser.email ?? existingUser.email,
            displayName: firebaseUser.displayName ?? existingUser.displayName,
            photoURL: firebaseUser.photoURL ?? existingUser.photoURL,
            lastLoginAt: DateTime.now(),
            linkedAccounts: {...existingUser.linkedAccounts, 'facebook': true},
          );
          await dbService.updateUser(updatedUser);
          return updatedUser;
        } else {
          final newUser = models.User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName,
            photoURL: firebaseUser.photoURL,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            linkedAccounts: {'facebook': true},
          );
          await dbService.createUser(newUser);
          return newUser;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Error in signInWithFacebook: $e');
      rethrow;
    }
  }

  Future<void> signInAsGuest() async {
    _isGuestMode = true;
    await _localStorage.setGuestMode(true);
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      if (_isGuestMode) {
        _isGuestMode = false;
        await _localStorage.clearGuestData();
      } else {
        await Future.wait([
          _auth.signOut(),
          _googleSignIn.signOut(),
        ]);
        _currentUser = null;
        await _prefs?.remove('user_id');
      }
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // When converting from guest to authenticated user
  Future<void> convertGuestToUser(models.User user) async {
    if (!_isGuestMode) return;

    final dbService = DatabaseService();
    await dbService.transferGuestPetsToUser(user.id);
    _isGuestMode = false;
    await _localStorage.setGuestMode(false);
    _currentUser = user;
    notifyListeners();
  }

  void updateCurrentUser(models.User user) {
    _currentUser = user;
    notifyListeners();
  }
} 