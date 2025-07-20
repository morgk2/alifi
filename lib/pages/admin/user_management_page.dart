import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/database_service.dart';
import '../../widgets/spinning_loader.dart';
import '../../widgets/verification_badge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _searchController = TextEditingController();
  final _databaseService = DatabaseService();
  final _scrollController = ScrollController();
  List<User> _searchResults = [];
  List<User> _allUsers = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreUsers = true;
  DocumentSnapshot? _lastDocument;
  bool _viewingAllUsers = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_viewingAllUsers) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200 && !_isLoadingMore && _hasMoreUsers) {
      _loadMoreUsers();
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoadingMore || !_hasMoreUsers) return;

    setState(() => _isLoadingMore = true);

    try {
      final users = await _databaseService.getAllUsers(
        startAfter: _lastDocument,
      );
      
      if (users.isEmpty) {
        setState(() => _hasMoreUsers = false);
      } else {
        setState(() {
          _allUsers.addAll(users);
          _lastDocument = FirebaseFirestore.instance
              .collection('users')
              .doc(users.last.id)
              .get() as DocumentSnapshot<Object?>;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more users: $e')),
      );
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    setState(() => _viewingAllUsers = false);
    
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final users = await _databaseService.searchUsers(
        displayName: query,
        username: query,
        email: query,
        limit: 50,
      );
      if (mounted) {
        setState(() {
          _searchResults = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching users: $e')),
        );
      }
    }
  }

  Future<void> _viewAllUsers() async {
    _searchController.clear();
    setState(() {
      _viewingAllUsers = true;
      _isLoading = true;
      _allUsers = [];
      _lastDocument = null;
      _hasMoreUsers = true;
    });

    try {
      final users = await _databaseService.getAllUsers();
      if (mounted) {
        setState(() {
          _allUsers = users;
          if (users.isNotEmpty) {
            _lastDocument = FirebaseFirestore.instance
                .collection('users')
                .doc(users.last.id)
                .get() as DocumentSnapshot<Object?>;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  void _showUserEditDialog(User user) {
    String selectedAccountType = user.accountType;
    bool isVerified = user.isVerified;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Display Name: ${user.displayName ?? 'N/A'}'),
            Text('Username: ${user.username ?? 'N/A'}'),
            const SizedBox(height: 16),
            const Text('Account Type:'),
            StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Normal'),
                    value: 'normal',
                    groupValue: selectedAccountType,
                    onChanged: (value) => setState(() => selectedAccountType = value!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Store'),
                    value: 'store',
                    groupValue: selectedAccountType,
                    onChanged: (value) => setState(() => selectedAccountType = value!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Vet'),
                    value: 'vet',
                    groupValue: selectedAccountType,
                    onChanged: (value) => setState(() => selectedAccountType = value!),
                  ),
                  CheckboxListTile(
                    title: const Text('Verified'),
                    value: isVerified,
                    onChanged: (value) => setState(() => isVerified = value!),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final updatedUser = user.copyWith(
                  accountType: selectedAccountType,
                  isVerified: isVerified,
                );
                await _databaseService.updateUser(updatedUser);
                if (mounted) {
                  Navigator.pop(context);
                  // Refresh the current view
                  if (_viewingAllUsers) {
                    _viewAllUsers();
                  } else {
                    _searchUsers(_searchController.text);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User updated successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating user: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
        child: user.photoURL == null
            ? Text(
                user.displayName?[0].toUpperCase() ?? user.email[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
      title: Row(
        children: [
          Text(user.displayName ?? 'No name'),
          if (user.isVerified) ...[
            const SizedBox(width: 4),
            const VerificationBadge(size: 16),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email),
          Text(
            'Account Type: ${user.accountType[0].toUpperCase()}${user.accountType.substring(1)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
      onTap: () => _showUserEditDialog(user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedUsers = _viewingAllUsers ? _allUsers : _searchResults;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users by name, email, or username',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: _searchUsers,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _viewAllUsers,
                    icon: const Icon(Icons.people),
                    label: const Text('View All Accounts'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: SpinningLoader(color: Colors.orange))
                : displayedUsers.isEmpty
                    ? Center(
                        child: Text(
                          _viewingAllUsers
                              ? 'No users found'
                              : _searchController.text.isEmpty
                                  ? 'Search for users to manage'
                                  : 'No users found',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: displayedUsers.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == displayedUsers.length) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: SpinningLoader(color: Colors.orange)),
                            );
                          }
                          return _buildUserTile(displayedUsers[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 