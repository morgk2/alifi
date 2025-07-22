import 'package:flutter/material.dart';
import 'bulk_import_page.dart';
import 'user_management_page.dart';
import 'add_product_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

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
              context,
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
              context,
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
            
            // Bulk Import Card
            _buildAdminCard(
              context,
              title: 'Bulk Import',
              description: 'Import multiple products from JSON data.',
              icon: Icons.upload_file,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BulkImportPage(
                      showLocationFetch: false,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Location Deep Fetch Card
            _buildAdminCard(
              context,
              title: 'Location Deep Fetch',
              description: 'Update the database with new vet clinics and pet stores from all major cities.',
              icon: Icons.location_searching,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BulkImportPage(
                      showLocationFetch: true,
                      showBulkImport: false,
                    ),
                  ),
                );
              },
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: color ?? Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 