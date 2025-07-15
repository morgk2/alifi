import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../pages/user_profile_page.dart';
import '../widgets/spinning_loader.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final _searchController = TextEditingController();
  final _databaseService = DatabaseService();
  List<User> _searchResults = [];
  List<User> _recentUsers = [];
  bool _isLoading = false;
  bool _showingAllUsers = false;

  @override
  void initState() {
    super.initState();
    _loadRecentUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _databaseService.getRecentUsers();
      setState(() {
        _recentUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  Future<void> _showAllUsers() async {
    setState(() {
      _isLoading = true;
      _showingAllUsers = true;
      _searchController.clear();
    });
    try {
      final users = await _databaseService.getAllUsers();
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
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    setState(() => _showingAllUsers = false);
    
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
      );
      setState(() {
        _searchResults = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching users: $e')),
        );
      }
    }
  }

  void _viewUserProfile(BuildContext context, User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(user: user),
      ),
    );
  }

  Widget _buildUserCard(User user) {
    final currentUser = context.read<AuthService>().currentUser;
    final isCurrentUser = currentUser?.id == user.id;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.photoURL != null
              ? NetworkImage(user.photoURL!)
              : null,
          child: user.photoURL == null
              ? Text(user.displayName?[0].toUpperCase() ?? user.email[0].toUpperCase())
              : null,
        ),
        title: Text(user.displayName ?? 'No name'),
        subtitle: Text(user.username ?? user.email),
        trailing: isCurrentUser
            ? const Chip(
                label: Text('You'),
                backgroundColor: Colors.blue,
                labelStyle: TextStyle(color: Colors.white),
              )
            : const Icon(Icons.chevron_right),
        onTap: () => _viewUserProfile(context, user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Users'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, username, or email',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onChanged: _searchUsers,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: SpinningLoader(color: Colors.orange))
          : Column(
              children: [
                // Show All Users button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _showAllUsers,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(_showingAllUsers ? 'Showing All Users' : 'Show All Users'),
                  ),
                ),
                Expanded(
                  child: _searchController.text.isEmpty && !_showingAllUsers
                    ? ListView(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Recent Users',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ..._recentUsers.map(_buildUserCard),
                        ],
                      )
                    : _searchResults.isEmpty
                        ? const Center(
                            child: Text('No users found'),
                          )
                        : ListView(
                            children: _searchResults.map(_buildUserCard).toList(),
                          ),
                ),
              ],
            ),
    );
  }
} 