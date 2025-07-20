import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as models;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'local_storage_service.dart';
import 'database_service.dart';
import 'dart:math';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '261633708467-uba68ge1mau5e89pf9ip7u55hb93l0p0.apps.googleusercontent.com' : null,
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();
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

  Future<models.User?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process...');
      GoogleSignInAccount? googleUser;
      
      if (kIsWeb) {
        print('Web platform detected, using web sign-in flow');
        try {
          googleUser = await _googleSignIn.signIn();
          print('Web Google Sign-In completed: ${googleUser?.email}');
        } catch (e) {
          print('Error during web Google sign in: $e');
          rethrow;
        }
      } else {
        print('Mobile platform detected, using mobile sign-in flow');
        
        try {
          // Try interactive sign-in directly
          print('Starting interactive Google Sign-In...');
          googleUser = await _googleSignIn.signIn();
          
          if (googleUser == null) {
            print('Interactive Google Sign-In cancelled by user');
            return null;
          }
          
          print('Interactive Google Sign-In successful: ${googleUser.email}');
        } catch (e) {
          print('Error during interactive Google Sign-In: $e');
          rethrow;
        }
      }

      if (googleUser == null) {
        print('Google Sign-In returned null user');
        return null;
      }

      try {
        print('Getting Google authentication...');
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        print('Got Google authentication tokens');

        print('Creating Firebase credential...');
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        print('Signing in to Firebase...');
        final userCredential = await _auth.signInWithCredential(credential);
        final firebaseUser = userCredential.user;

        if (firebaseUser == null) {
          print('Firebase sign-in failed: null user');
          return null;
        }

        print('Firebase sign-in successful: ${firebaseUser.email}');

        // Create or update user document
        final userData = models.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          photoURL: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          linkedAccounts: {'google': true},
        );

        await DatabaseService().createUser(userData);
        print('User data saved to Firestore');

        return userData;
      } catch (e) {
        print('Error during Firebase sign-in: $e');
        rethrow;
      }
    } catch (e) {
      print('Error in signInWithGoogle: $e');
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