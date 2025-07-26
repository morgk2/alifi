import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

Future<void> main() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('Fetching locations from Firestore...');
    final firestore = FirebaseFirestore.instance;

    // Get vets document
    final vetsDoc = await firestore.collection('locations').doc('vets').get();
    final vetsData = vetsDoc.data()?['locations'] ?? {};
    print('Found ${vetsData.length} vet locations');

    // Get stores document
    final storesDoc = await firestore.collection('locations').doc('stores').get();
    final storesData = storesDoc.data()?['locations'] ?? {};
    print('Found ${storesData.length} store locations');

    // Create locations data structure
    final locationsData = {
      'vets': vetsData,
      'stores': storesData,
    };

    // Create assets/data directory if it doesn't exist
    final directory = Directory('assets/data');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    // Write to JSON file
    final file = File('assets/data/locations.json');
    await file.writeAsString(
      JsonEncoder.withIndent('  ').convert(locationsData),
      flush: true,
    );

    print('Successfully exported locations to assets/data/locations.json');
    print('JSON structure:');
    print('- vets: ${vetsData.length} locations');
    print('- stores: ${storesData.length} locations');

  } catch (e) {
    print('Error exporting locations: $e');
  }

  exit(0);
} 