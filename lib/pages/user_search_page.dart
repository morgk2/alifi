import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/local_storage_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../pages/user_profile_page.dart';
import '../widgets/spinning_loader.dart';
import '../widgets/verification_badge.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final _searchController = TextEditingController();
  final _databaseService = DatabaseService();
  final _localStorageService = LocalStorageService();
  List<User> _searchResults = [];
  List<User> _recentProfiles = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadRecentProfiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentProfiles() async {
    final profiles = await _localStorageService.getRecentProfiles();
    setState(() => _recentProfiles = profiles);
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
    });

    try {
      final users = await _databaseService.searchUsers(
        displayName: query,
        username: query,
        email: query,
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

  void _viewUserProfile(BuildContext context, User user) async {
    // Add to recent profiles before navigating
    await _localStorageService.addRecentProfile(user);
    // Reload recent profiles immediately to show the change
    await _loadRecentProfiles();
    
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfilePage(user: user),
        ),
      );
      
      // Reload recent profiles again when returning from profile page
      await _loadRecentProfiles();
    }
  }

  Widget _buildUserTile(User user) {
    final currentUser = context.read<AuthService>().currentUser;
    final isCurrentUser = currentUser?.id == user.id;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[200],
          backgroundImage: user.photoURL != null
              ? NetworkImage(user.photoURL!)
              : null,
          child: user.photoURL == null
              ? Text(
                  user.displayName?[0].toUpperCase() ?? user.email[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Text(
              user.displayName ?? 'No name',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (user.isVerified) ...[
              const SizedBox(width: 4),
              const VerificationBadge(),
            ],
          ],
        ),
        subtitle: Text(
          user.username ?? user.email,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: isCurrentUser
            ? const Text(
                'You',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              )
            : const Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey,
              ),
        onTap: () => _viewUserProfile(context, user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchUsers,
                decoration: InputDecoration(
                  hintText: 'Search people, pets, vets...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _searchUsers('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: SpinningLoader(color: Colors.orange))
                : CustomScrollView(
                    slivers: [
                      if (!_isSearching) ...[
                        const SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              'Recents',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        if (_recentProfiles.isEmpty)
                          const SliverFillRemaining(
                            child: Center(
                              child: Text(
                                'No recent profiles',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildUserTile(_recentProfiles[index]),
                              childCount: _recentProfiles.length,
                            ),
                          ),
                      ] else if (_searchResults.isEmpty)
                        const SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'No users found',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildUserTile(_searchResults[index]),
                            childCount: _searchResults.length,
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
} 