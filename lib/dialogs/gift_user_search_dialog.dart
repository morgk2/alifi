import 'package:alifi/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

class GiftUserSearchDialog extends StatefulWidget {
  final String productId;
  final String productName;
  final String productImage;
  final double productPrice;
  final String productType; // 'store' or 'aliexpress'

  const GiftUserSearchDialog({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.productType,
  });

  @override
  State<GiftUserSearchDialog> createState() => _GiftUserSearchDialogState();
}

class _GiftUserSearchDialogState extends State<GiftUserSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _performSearch();
  }

  Future<void> _performSearch() async {
    if (_searchQuery.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Simulate search delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // TODO: Implement actual user search
      // For now, show mock results
      setState(() {
        _searchResults = [
          User(
            id: '1',
            email: 'user1@example.com',
            displayName: 'John Doe',
            photoURL: null,
          ),
          User(
            id: '2',
            email: 'user2@example.com',
            displayName: 'Jane Smith',
            photoURL: null,
          ),
        ];
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _giftToUser(User user) {
    showDialog(
      context: context,
      builder: (context) => _GiftConfirmationDialog(
        user: user,
        productName: widget.productName,
        productPrice: widget.productPrice,
        onConfirm: () => _confirmGift(user),
      ),
    );
  }

  Future<void> _confirmGift(User user) async {
    try {
      final authService = context.read<AuthService>();
      final currentUser = authService.currentUser;
      
      if (currentUser == null) return;

      // TODO: Implement actual gift creation
      final gift = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'gifterId': currentUser.id,
        'gifterName': currentUser.displayName ?? AppLocalizations.of(context)!.anonymous,
        'recipientId': user.id,
        'recipientName': user.displayName ?? AppLocalizations.of(context)!.noName,
        'productId': widget.productId,
        'productName': widget.productName,
        'productImage': widget.productImage,
        'productPrice': widget.productPrice,
        'productType': widget.productType == 'store' ? 'store' : 'aliexpress',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // TODO: Save gift to database
      print('Gift created: $gift');

      if (mounted) {
        Navigator.of(context).pop(); // Close confirmation dialog
        Navigator.of(context).pop(); // Close search dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gift sent to ${user.displayName ?? AppLocalizations.of(context)!.noName}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending gift: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.giftToAFriend,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.productName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Search Section
            Container(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchByNameOrEmail,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            
            // Results Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _searchQuery.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context)!.searchForUsersToGift,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      )
                    : _isSearching
                        ? const Center(child: CircularProgressIndicator())
                        : _searchResults.isEmpty
                            ? Center(
                                child: Text(
                                  AppLocalizations.of(context)!.noUsersFound,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final user = _searchResults[index];
                                  return _UserListItem(
                                    user: user,
                                    onGift: () => _giftToUser(user),
                                  );
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final User user;
  final VoidCallback onGift;

  const _UserListItem({
    required this.user,
    required this.onGift,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null
                ? Text(
                    (user.displayName ?? AppLocalizations.of(context)!.noName)[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? AppLocalizations.of(context)!.noName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  user.email ?? AppLocalizations.of(context)!.noEmail,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onGift,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.gift),
          ),
        ],
      ),
    );
  }
}

class _GiftConfirmationDialog extends StatelessWidget {
  final User user;
  final String productName;
  final double productPrice;
  final VoidCallback onConfirm;

  const _GiftConfirmationDialog({
    required this.user,
    required this.productName,
    required this.productPrice,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.confirmYourGift),
      content: Text(
        AppLocalizations.of(context)!.areYouSureYouWantToGiftThisProductTo(user.displayName ?? AppLocalizations.of(context)!.noName),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text(AppLocalizations.of(context)!.confirm),
        ),
      ],
    );
  }
}

class User {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoURL;

  User({
    required this.id,
    this.email,
    this.displayName,
    this.photoURL,
  });
} 