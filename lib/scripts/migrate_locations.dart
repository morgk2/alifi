import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> migrateLocations() async {
  final firestore = FirebaseFirestore.instance;
  
  // Create batch for atomic operations
  var batch = firestore.batch();
  int operationCount = 0;
  
  try {
    print('Starting location migration...');
    
    // Create the locations document references
    final vetsDoc = firestore.collection('locations').doc('vets');
    final storesDoc = firestore.collection('locations').doc('stores');
    
    // Get existing locations first
    print('Fetching existing locations...');
    final existingVetsDoc = await vetsDoc.get();
    final existingStoresDoc = await storesDoc.get();
    
    // Extract existing locations
    Map<String, dynamic> existingVetLocations = 
      (existingVetsDoc.data()?['locations'] as Map<String, dynamic>?) ?? {};
    Map<String, dynamic> existingStoreLocations = 
      (existingStoresDoc.data()?['locations'] as Map<String, dynamic>?) ?? {};
    
    print('Found ${existingVetLocations.length} existing vet locations');
    print('Found ${existingStoreLocations.length} existing store locations');
    
    // Get all vet locations
    print('Fetching vet locations from old collection...');
    final vetDocs = await firestore.collection('vet_locations').get();
    
    // Prepare vet locations data
    Map<String, dynamic> vetLocations = Map.from(existingVetLocations);
    int newVetCount = 0;
    for (var doc in vetDocs.docs) {
      final data = doc.data();
      if (data['location'] != null && !vetLocations.containsKey(doc.id)) {
        vetLocations[doc.id] = {
          'location': data['location'],
          'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
        };
        newVetCount++;
      }
    }
    
    // Set vet locations if there are new ones
    if (newVetCount > 0) {
      batch.set(vetsDoc, {'locations': vetLocations});
      print('Prepared $newVetCount new vet locations');
      operationCount++;
    } else {
      print('No new vet locations to migrate');
    }
    
    // Get all store locations
    print('Fetching store locations from old collection...');
    final storeDocs = await firestore.collection('store_locations').get();
    
    // Prepare store locations data
    Map<String, dynamic> storeLocations = Map.from(existingStoreLocations);
    int newStoreCount = 0;
    for (var doc in storeDocs.docs) {
      final data = doc.data();
      if (data['location'] != null && !storeLocations.containsKey(doc.id)) {
        storeLocations[doc.id] = {
          'location': data['location'],
          'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
        };
        newStoreCount++;
      }
    }
    
    // Set store locations if there are new ones
    if (newStoreCount > 0) {
      batch.set(storesDoc, {'locations': storeLocations});
      print('Prepared $newStoreCount new store locations');
      operationCount++;
    } else {
      print('No new store locations to migrate');
    }
    
    // Commit the batch if there are any changes
    if (operationCount > 0) {
      print('Committing changes...');
      await batch.commit();
      print('Migration completed successfully');
      print('Migrated $newVetCount new vet locations and $newStoreCount new store locations');
      print('Total locations after migration:');
      print('- Vets: ${vetLocations.length}');
      print('- Stores: ${storeLocations.length}');
    } else {
      print('No new locations to migrate');
    }
    
  } catch (e) {
    print('Error during migration: $e');
    throw e;
  }
}

// Optional: Function to verify migration
Future<void> verifyMigration() async {
  final firestore = FirebaseFirestore.instance;
  
  try {
    print('\nVerifying migration...');
    
    // Check new locations
    final vetsDoc = await firestore.collection('locations').doc('vets').get();
    final storesDoc = await firestore.collection('locations').doc('stores').get();
    
    final vetLocations = vetsDoc.data()?['locations'] as Map<String, dynamic>? ?? {};
    final storeLocations = storesDoc.data()?['locations'] as Map<String, dynamic>? ?? {};
    
    print('Found ${vetLocations.length} vet locations in new structure');
    print('Found ${storeLocations.length} store locations in new structure');
    
    // Check old collections
    final oldVetCount = await firestore.collection('vet_locations').count().get();
    final oldStoreCount = await firestore.collection('store_locations').count().get();
    
    print('\nOld collections:');
    print('Vet locations: ${oldVetCount.count}');
    print('Store locations: ${oldStoreCount.count}');
    
    // Check for duplicates
    final vetPlaceIds = vetLocations.keys.toSet();
    final storePlaceIds = storeLocations.keys.toSet();
    
    print('\nChecking for duplicates...');
    if (vetPlaceIds.length == vetLocations.length && 
        storePlaceIds.length == storeLocations.length) {
      print('No duplicate place IDs found ✓');
    } else {
      print('WARNING: Duplicate place IDs found!');
      print('Vet locations: ${vetLocations.length} total, ${vetPlaceIds.length} unique');
      print('Store locations: ${storeLocations.length} total, ${storePlaceIds.length} unique');
    }
    
    // Verify all old locations are in new structure
    final oldVetDocs = await firestore.collection('vet_locations').get();
    final oldStoreDocs = await firestore.collection('store_locations').get();
    
    final missingVets = oldVetDocs.docs
        .where((doc) => !vetLocations.containsKey(doc.id))
        .map((doc) => doc.id)
        .toList();
        
    final missingStores = oldStoreDocs.docs
        .where((doc) => !storeLocations.containsKey(doc.id))
        .map((doc) => doc.id)
        .toList();
    
    if (missingVets.isEmpty && missingStores.isEmpty) {
      print('\nAll locations were migrated successfully ✓');
    } else {
      print('\nWARNING: Some locations were not migrated:');
      if (missingVets.isNotEmpty) {
        print('Missing vet locations: ${missingVets.join(", ")}');
      }
      if (missingStores.isNotEmpty) {
        print('Missing store locations: ${missingStores.join(", ")}');
      }
    }
    
  } catch (e) {
    print('Error during verification: $e');
    throw e;
  }
}

// Optional: Function to cleanup old collections after successful migration
Future<void> cleanupOldCollections() async {
  final firestore = FirebaseFirestore.instance;
  
  try {
    print('\nCleaning up old collections...');
    
    // Delete in batches of 500 (Firestore limit)
    Future<void> deleteCollection(String collectionPath) async {
      final collection = firestore.collection(collectionPath);
      final batchSize = 500;
      
      while (true) {
        final docs = await collection.limit(batchSize).get();
        if (docs.docs.isEmpty) break;
        
        var batch = firestore.batch();
        for (var doc in docs.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        
        print('Deleted ${docs.docs.length} documents from $collectionPath');
      }
    }
    
    await deleteCollection('vet_locations');
    await deleteCollection('store_locations');
    
    print('Cleanup completed successfully');
    
  } catch (e) {
    print('Error during cleanup: $e');
    throw e;
  }
} 