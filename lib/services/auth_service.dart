import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as models;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'local_storage_service.dart';
import 'database_service.dart';

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
        if (firebaseUser == null) {
          _currentUser = null;
          await _prefs?.remove('user_id');
          // Don't notify if in guest mode
          if (!_isGuestMode) {
            notifyListeners();
          }
        } else {
          await _loadUserData(firebaseUser.uid);
        }
      }, onError: (error) {
        print('Error in auth state listener: $error');
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
      GoogleSignInAccount? googleUser;
      
      if (kIsWeb) {
        // For web, try interactive sign in directly
        try {
          googleUser = await _googleSignIn.signIn();
        } catch (e) {
          print('Error during Google sign in: $e');
          // If there's a popup error, try signing out first
          if (e.toString().contains('popup_closed_by_user') || 
              e.toString().contains('popup_blocked')) {
            await _googleSignIn.signOut();
            await _auth.signOut();
            // Try sign in again
            googleUser = await _googleSignIn.signIn();
          } else {
            rethrow;
          }
        }
      } else {
        // For mobile, sign out first to prevent duplicate ID issues
        await _googleSignIn.signOut();
        await _auth.signOut();
        googleUser = await _googleSignIn.signIn();
      }
      
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      // Check if user exists in Firestore
      final userDoc = _firestore.collection('users').doc(user.uid);
      
      try {
        final userSnapshot = await userDoc.get();

        if (!userSnapshot.exists) {
          // Create new user document
          final newUser = models.User(
            id: user.uid,
            email: user.email!,
            displayName: user.displayName,
            photoURL: user.photoURL,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            linkedAccounts: {'google': true},
          );
          await userDoc.set(newUser.toFirestore());
          _currentUser = newUser;
          await _prefs?.setString('user_id', user.uid);
        } else {
          // Update existing user's last login
          final existingUser = models.User.fromFirestore(userSnapshot);
          final updatedUser = existingUser.copyWith(
            lastLoginAt: DateTime.now(),
            linkedAccounts: {...existingUser.linkedAccounts, 'google': true},
          );
          await userDoc.update(updatedUser.toFirestore());
          _currentUser = updatedUser;
          await _prefs?.setString('user_id', user.uid);
        }

        notifyListeners();
        return _currentUser;
      } catch (e) {
        print('Error accessing Firestore: $e');
        // Even if Firestore fails, return a basic user object
        _currentUser = models.User(
          id: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoURL: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          linkedAccounts: {'google': true},
        );
        await _prefs?.setString('user_id', user.uid);
        notifyListeners();
        return _currentUser;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
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
} 