import 'package:flutter/material.dart';
import 'bulk_import_page.dart';
import 'user_management_page.dart';
import 'add_product_page.dart';
import 'add_aliexpress_product_page.dart';
import '../../services/database_service.dart';
import '../../widgets/spinning_loader.dart';
import 'pet_id_management_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isMigrating = false;

  Future<void> _migrateLocations() async {
    if (_isMigrating) return;

    try {
      setState(() => _isMigrating = true);

      // Show confirmation dialog
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Migrate Locations'),
          content: const Text(
            'This will migrate all locations from the old collections (vet_locations and store_locations) '
            'to the new locations collection. This process cannot be undone.\n\n'
            'Are you sure you want to proceed?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('PROCEED'),
            ),
          ],
        ),
      ) ?? false;

      if (!shouldProceed) {
        setState(() => _isMigrating = false);
        return;
      }

      // Start migration
      final dbService = DatabaseService();
      await dbService.migrateLocations();

      // Show success dialog
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Migration Complete'),
            content: const Text(
              'All locations have been successfully migrated to the new structure.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Show error dialog
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Migration Failed'),
            content: Text('Error during migration: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isMigrating = false);
      }
    }
  }

  Widget _buildAdminCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading) 
                const SpinningLoader(size: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Admin Tools',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // User Management Card
            _buildAdminCard(
              title: 'User Management',
              description: 'Manage user accounts, roles, and permissions.',
              icon: Icons.people,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserManagementPage()),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Product Management Card
            _buildAdminCard(
              title: 'Add Products',
              description: 'Add new products to the marketplace.',
              icon: Icons.add_shopping_cart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddProductPage()),
                );
              },
            ),
            
            const SizedBox(height: 16),

            // AliExpress Product Card
            _buildAdminCard(
              title: 'Add AliExpress Product',
              description: 'Add new products from AliExpress.',
              icon: Icons.shopping_basket,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddAliexpressProductPage()),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Bulk Import Card
            _buildAdminCard(
              title: 'Bulk Import',
              description: 'Import multiple products at once.',
              icon: Icons.upload_file,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BulkImportPage()),
                );
              },
            ),

            const SizedBox(height: 16),

            // Migrate Locations Card
            _buildAdminCard(
              title: 'Migrate Locations',
              description: 'Migrate vet and store locations to the new structure.',
              icon: Icons.location_on,
              onTap: _migrateLocations,
              isLoading: _isMigrating,
            ),

            const SizedBox(height: 16),

            // Pet ID Management Card
            _buildAdminCard(
              title: 'Pet ID Management',
              description: 'Review and manage digital and physical pet ID requests.',
              icon: Icons.pets,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PetIdManagementPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 