import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/spinning_loader.dart';

class PetIdManagementPage extends StatefulWidget {
  const PetIdManagementPage({Key? key}) : super(key: key);

  @override
  State<PetIdManagementPage> createState() => _PetIdManagementPageState();
}

class _PetIdManagementPageState extends State<PetIdManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updatePetIdStatus(String docId, bool isAvailable, String? idUrl) async {
    try {
      setState(() => _isLoading = true);
      
      final updateData = <String, dynamic>{
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (idUrl != null && idUrl.isNotEmpty) {
        updateData['idUrl'] = idUrl;
      }
      
      await FirebaseFirestore.instance
          .collection('petId')
          .doc(docId)
          .update(updateData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pet ID status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating pet ID: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updatePhysicalPetIdStatus(String docId, String status) async {
    try {
      setState(() => _isLoading = true);
      
      await FirebaseFirestore.instance
          .collection('physicalPetIds')
          .doc(docId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Physical Pet ID status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating physical pet ID: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showEditPetIdDialog(Map<String, dynamic> petIdData, String docId) {
    final isAvailableController = TextEditingController(
      text: (petIdData['isAvailable'] ?? false).toString(),
    );
    final idUrlController = TextEditingController(
      text: petIdData['idUrl'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pet ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pet: ${petIdData['petId']}'),
            const SizedBox(height: 16),
            TextField(
              controller: idUrlController,
              decoration: const InputDecoration(
                labelText: 'ID Image URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Available: '),
                Switch(
                  value: petIdData['isAvailable'] ?? false,
                  onChanged: (value) {
                    isAvailableController.text = value.toString();
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updatePetIdStatus(
                docId,
                isAvailableController.text == 'true',
                idUrlController.text.trim(),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditPhysicalPetIdDialog(Map<String, dynamic> physicalIdData, String docId) {
    String selectedStatus = physicalIdData['status'] ?? 'pending';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Physical Pet ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pet: ${physicalIdData['petName']}'),
            Text('Customer: ${physicalIdData['fullName']}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'processing', child: Text('Processing')),
                DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) {
                selectedStatus = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updatePhysicalPetIdStatus(docId, selectedStatus);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildPetIdCard(Map<String, dynamic> petIdData, String docId) {
    final isAvailable = petIdData['isAvailable'] ?? false;
    final petName = petIdData['petId'] ?? 'Unknown';
    final userId = petIdData['userId'] ?? '';
    final idUrl = petIdData['idUrl'] ?? '';
    final createdAt = petIdData['createdAt'] as Timestamp?;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          petName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User ID: $userId'),
            Text('Status: ${isAvailable ? 'Available' : 'Processing'}'),
            if (createdAt != null)
              Text('Requested: ${createdAt.toDate().toString().split('.')[0]}'),
            if (idUrl.isNotEmpty)
              Text('ID URL: ${idUrl.length > 50 ? '${idUrl.substring(0, 50)}...' : idUrl}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAvailable ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isAvailable ? 'Ready' : 'Processing',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditPetIdDialog(petIdData, docId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalPetIdCard(Map<String, dynamic> physicalIdData, String docId) {
    final status = physicalIdData['status'] ?? 'pending';
    final petName = physicalIdData['petName'] ?? 'Unknown';
    final fullName = physicalIdData['fullName'] ?? '';
    final address = physicalIdData['address'] ?? '';
    final phoneNumber = physicalIdData['phoneNumber'] ?? '';
    final requestedAt = physicalIdData['requestedAt'] as Timestamp?;

    Color statusColor;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'processing':
        statusColor = Colors.blue;
        break;
      case 'shipped':
        statusColor = Colors.purple;
        break;
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        title: Text(
          petName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Customer: $fullName'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditPhysicalPetIdDialog(physicalIdData, docId),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Phone: $phoneNumber'),
                const SizedBox(height: 8),
                Text('Address: $address'),
                if (requestedAt != null) ...[
                  const SizedBox(height: 8),
                  Text('Requested: ${requestedAt.toDate().toString().split('.')[0]}'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet ID Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Digital Pet IDs'),
            Tab(text: 'Physical Pet IDs'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              // Digital Pet IDs Tab
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('petId')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: SpinningLoader());
                  }

                  final petIds = snapshot.data?.docs ?? [];

                  if (petIds.isEmpty) {
                    return const Center(
                      child: Text('No pet ID requests found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: petIds.length,
                    itemBuilder: (context, index) {
                      final doc = petIds[index];
                      return _buildPetIdCard(doc.data() as Map<String, dynamic>, doc.id);
                    },
                  );
                },
              ),
              
              // Physical Pet IDs Tab
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('physicalPetIds')
                    .orderBy('requestedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: SpinningLoader());
                  }

                  final physicalPetIds = snapshot.data?.docs ?? [];

                  if (physicalPetIds.isEmpty) {
                    return const Center(
                      child: Text('No physical pet ID requests found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: physicalPetIds.length,
                    itemBuilder: (context, index) {
                      final doc = physicalPetIds[index];
                      return _buildPhysicalPetIdCard(doc.data() as Map<String, dynamic>, doc.id);
                    },
                  );
                },
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: SpinningLoader()),
            ),
        ],
      ),
    );
  }
} 