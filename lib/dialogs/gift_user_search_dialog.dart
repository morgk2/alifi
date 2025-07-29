import 'package:alifi/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gift.dart';
import '../models/user.dart';
import '../models/store_product.dart';
import '../services/database_service.dart';
import '../widgets/spinning_loader.dart';

class GiftUserSearchDialog extends StatefulWidget {
  final dynamic product;

  const GiftUserSearchDialog({super.key, required this.product});

  @override
  State<GiftUserSearchDialog> createState() => _GiftUserSearchDialogState();
}

class _GiftUserSearchDialogState extends State<GiftUserSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<User>>? _searchResults;

  void _searchUsers(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _searchResults = DatabaseService().searchUsers(displayName: query);
      });
    } else {
      setState(() {
        _searchResults = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Gift to a Friend',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or email',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                ),
                onChanged: _searchUsers,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _searchResults == null
                    ? const Center(child: Text('Search for users to gift.'))
                    : FutureBuilder<List<User>>(
                        future: _searchResults,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SpinningLoader();
                          }
                          if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No users found.'));
                          }
                          final users = snapshot.data!;
                          return ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: user.photoURL != null
                                      ? NetworkImage(user.photoURL!)
                                      : null,
                                  child: user.photoURL == null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                title: Text(user.displayName ?? 'No Name'),
                                subtitle: Text(user.email ?? 'No Email'),
                                trailing: ElevatedButton(
                                  child: const Text('Gift'),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) =>
                                          _ConfirmGiftDialog(
                                        user: user,
                                        product: widget.product,
                                        onConfirm: () {
                                          final authService =
                                              Provider.of<AuthService>(context,
                                                  listen: false);
                                          final gifter = authService.currentUser;
                                          if (gifter == null) {
                                            // Handle not logged in case
                                            return;
                                          }

                                          final newGift = Gift(
                                            id: '', // Firestore will generate
                                            gifterId: gifter.id,
                                            gifterName:
                                                gifter.displayName ?? 'Anonymous',
                                            gifterPhotoUrl: gifter.photoURL,
                                            gifteeId: user.id,
                                            productId: widget.product.id,
                                            productName: widget.product.name,
                                            productImageUrl:
                                                widget.product.imageUrls.first,
                                            productType:
                                                widget.product is StoreProduct
                                                    ? 'store'
                                                    : 'aliexpress',
                                            status: 'pending',
                                            createdAt: DateTime.now(),
                                          );

                                          DatabaseService().sendGift(newGift);

                                          Navigator.of(dialogContext)
                                              .pop(); // Close confirmation
                                          Navigator.of(context)
                                              .pop(); // Close search dialog
                                        },
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmGiftDialog extends StatelessWidget {
  final User user;
  final dynamic product;
  final VoidCallback onConfirm;

  const _ConfirmGiftDialog({
    required this.user,
    required this.product,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Confirm Your Gift',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text(
              'Are you sure you want to gift this product to ${user.displayName}?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(fontSize: 16, color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.green,
                      elevation: 0,
                    ),
                    child: const Text('Confirm',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
} 