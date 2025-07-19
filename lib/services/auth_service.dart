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
        // For web, try interactive sign in directly
        try {
          googleUser = await _googleSignIn.signIn().timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('Google Sign-In timed out on web');
              throw TimeoutException('Google Sign-In timed out');
            },
          );
          print('Web Google Sign-In completed: ${googleUser?.email}');
        } catch (e) {
          print('Error during Google sign in: $e');
          // If there's a popup error, try signing out first
          if (e.toString().contains('popup_closed_by_user') || 
              e.toString().contains('popup_blocked')) {
            print('Popup error detected, trying sign out and retry...');
            await _googleSignIn.signOut();
            await _auth.signOut();
            // Try sign in again
            googleUser = await _googleSignIn.signIn().timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                print('Google Sign-In retry timed out on web');
                throw TimeoutException('Google Sign-In retry timed out');
              },
            );
            print('Retry Google Sign-In completed: ${googleUser?.email}');
          } else {
            rethrow;
          }
        }
      } else {
        print('Mobile platform detected, using mobile sign-in flow');
        // For mobile, sign out first to prevent duplicate ID issues
        print('Signing out from previous sessions...');
        await _googleSignIn.signOut();
        await _auth.signOut();
        print('Previous sessions cleared, starting new sign-in...');
        
        try {
          googleUser = await _googleSignIn.signIn().timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('Google Sign-In timed out on mobile');
              throw TimeoutException('Google Sign-In timed out');
            },
          );
          print('Mobile Google Sign-In completed: ${googleUser?.email}');
        } catch (e) {
          print('Mobile Google Sign-In error: $e');
          // Try one more time without signing out first
          print('Retrying Google Sign-In without sign out...');
          try {
            googleUser = await _googleSignIn.signIn().timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                print('Google Sign-In retry timed out on mobile');
                throw TimeoutException('Google Sign-In retry timed out');
              },
            );
            print('Mobile Google Sign-In retry completed: ${googleUser?.email}');
          } catch (retryError) {
            print('Mobile Google Sign-In retry failed: $retryError');
            rethrow;
          }
        }
      }
      
      if (googleUser == null) {
        print('Google Sign-In returned null user');
        return null;
      }

      print('Getting Google authentication...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('Google authentication timed out');
          throw TimeoutException('Google authentication timed out');
        },
      );
      print('Google authentication obtained');
      
      print('Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in to Firebase with credential...');
      final userCredential = await _auth.signInWithCredential(credential).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('Firebase sign-in timed out');
          throw TimeoutException('Firebase sign-in timed out');
        },
      );
      final user = userCredential.user;
      if (user == null) {
        print('Firebase sign-in returned null user');
        return null;
      }
      print('Firebase sign-in successful: ${user.email}');

      // Check if user exists in Firestore
      print('Checking Firestore for existing user...');
      final userDoc = _firestore.collection('users').doc(user.uid);
      
      try {
        final userSnapshot = await userDoc.get().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('Firestore query timed out');
            throw TimeoutException('Firestore query timed out');
          },
        );
        print('Firestore query completed, user exists: ${userSnapshot.exists}');

        if (!userSnapshot.exists) {
          print('Creating new user document...');
          // Create new user document
          String? username = user.displayName;
          if (username == null || username.isEmpty) {
            print('Generating random username...');
            // Generate a random username without checking availability
            final rand = Random();
            username = 'user${rand.nextInt(90000) + 10000}';
            print('Generated username: $username');
          }
          final newUser = models.User(
            id: user.uid,
            email: user.email!,
            displayName: user.displayName,
            username: username,
            photoURL: user.photoURL,
            createdAt: DateTime.now(), // This will be overwritten by server timestamp
            lastLoginAt: DateTime.now(), // This will be overwritten by server timestamp
            linkedAccounts: {'google': true},
            followersCount: 0,
            followingCount: 0,
            followers: const [],
            following: const [],
            pets: const [],
          );
          // Use server timestamp when creating the document
          final userData = newUser.toFirestore();
          userData['createdAt'] = FieldValue.serverTimestamp();
          userData['lastLoginAt'] = FieldValue.serverTimestamp();
          await userDoc.set(userData).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('Firestore user creation timed out');
              throw TimeoutException('Firestore user creation timed out');
            },
          );
          print('New user document created successfully');
          _currentUser = newUser;
          await _prefs?.setString('user_id', user.uid);
        } else {
          print('Updating existing user...');
          // Update existing user's last login while preserving relationships and pets
          final existingUser = models.User.fromFirestore(userSnapshot);
          final updatedUser = existingUser.copyWith(
            lastLoginAt: DateTime.now(),
            linkedAccounts: {...existingUser.linkedAccounts, 'google': true},
            // Preserve existing relationships
            followers: existingUser.followers,
            following: existingUser.following,
            followersCount: existingUser.followersCount,
            followingCount: existingUser.followingCount,
            pets: existingUser.pets, // Preserve existing pets
          );
          await DatabaseService().updateUser(updatedUser);
          print('Existing user updated successfully');
          _currentUser = updatedUser;
          await _prefs?.setString('user_id', user.uid);
        }

        print('Notifying listeners and returning user...');
        notifyListeners();
        
        // Double-check that the auth state listener has been triggered
        print('Checking if Firebase auth state is properly set...');
        final currentFirebaseUser = _auth.currentUser;
        print('Current Firebase user: ${currentFirebaseUser?.email ?? 'null'}');
        
        return _currentUser;
      } catch (e) {
        print('Error accessing Firestore: $e');
        // Even if Firestore fails, return a basic user object
        print('Creating fallback user object...');
        _currentUser = models.User(
          id: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoURL: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          linkedAccounts: {'google': true},
          pets: const [], // Initialize empty pets array
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

  void updateCurrentUser(models.User user) {
    _currentUser = user;
    notifyListeners();
  }
} 