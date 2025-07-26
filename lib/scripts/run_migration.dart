import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';
import 'migrate_locations.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Sign in as admin
    print('\n=== Authenticating as Admin ===\n');
    // Replace these with your admin account credentials
    const email = 'your-admin-email@example.com';
    const password = 'your-admin-password';
    
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Failed to authenticate');
      }
      
      print('Successfully authenticated as ${user.email}');
    } catch (e) {
      print('Authentication failed: $e');
      print('\nPlease update the admin credentials in the script.');
      return;
    }

    print('\n=== Starting Migration Process ===\n');
    
    // Step 1: Run the migration
    print('Step 1: Migrating locations...');
    await migrateLocations();
    
    // Step 2: Verify the migration
    print('\nStep 2: Verifying migration...');
    await verifyMigration();
    
    // Step 3: Ask for confirmation before cleanup
    print('\nStep 3: Ready to clean up old collections');
    print('Please verify the migration results above.');
    print('To proceed with cleanup, uncomment the cleanup line in the code.');
    
    // Uncomment the following line when ready to clean up:
    // await cleanupOldCollections();
    
    print('\n=== Migration Process Completed ===\n');
    
    // Sign out after migration
    await FirebaseAuth.instance.signOut();
    
  } catch (e) {
    print('Error during migration process: $e');
    // Ensure we sign out even if there's an error
    await FirebaseAuth.instance.signOut();
  }
} 