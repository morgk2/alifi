import '../services/database_service.dart';

Future<void> main() async {
  print('Starting store stats update...');
  
  try {
    final databaseService = DatabaseService();
    await databaseService.updateAllStoreStats();
    print('Store stats update completed successfully!');
  } catch (e) {
    print('Error updating store stats: $e');
  }
} 