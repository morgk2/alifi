import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../l10n/app_localizations.dart';
import '../widgets/keyboard_dismissible_text_field.dart';

class UserSearchDialog extends StatefulWidget {
  final Function(String userId, String userName) onUserSelected;

  const UserSearchDialog({
    super.key,
    required this.onUserSelected,
  });

  @override
  State<UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<UserSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
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
          {
            'id': '1',
            'name': 'John Doe',
            'email': 'john@example.com',
            'photoURL': null,
          },
          {
            'id': '2',
            'name': 'Jane Smith',
            'email': 'jane@example.com',
            'photoURL': null,
          },
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

  void _selectUser(Map<String, dynamic> user) {
    widget.onUserSelected(user['id'], user['name']);
    Navigator.of(context).pop();
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
              child: Text(
                AppLocalizations.of(context)!.searchUsers,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            
            // Search Section
            Container(
              padding: const EdgeInsets.all(20),
              child: KeyboardDismissibleTextField(
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
                          AppLocalizations.of(context)!.typeToSearchForUsers,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      )
                    : _isSearching
                        ? const Center(
                            child: CupertinoActivityIndicator(
                              radius: 16,
                              color: Color(0xFFF59E0B),
                            ),
                          )
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
                                    onSelect: () => _selectUser(user),
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
  final Map<String, dynamic> user;
  final VoidCallback onSelect;

  const _UserListItem({
    required this.user,
    required this.onSelect,
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
            backgroundImage: user['photoURL'] != null ? NetworkImage(user['photoURL']) : null,
            child: user['photoURL'] == null
                ? Text(
                    (user['name'] ?? AppLocalizations.of(context)!.noName)[0].toUpperCase(),
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
                  user['name'] ?? AppLocalizations.of(context)!.noName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  user['email'] ?? AppLocalizations.of(context)!.noEmail,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onSelect,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.select),
          ),
        ],
      ),
    );
  }
} 