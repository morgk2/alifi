import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/pet.dart';
import '../services/database_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/spinning_loader.dart';

class UserProfilePage extends StatefulWidget {
  final User user;

  const UserProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _databaseService = DatabaseService();
  List<Pet> _userPets = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isLoadingFollow = false;

  @override
  void initState() {
    super.initState();
    _loadUserPets();
    _checkFollowStatus();
  }

  Future<void> _loadUserPets() async {
    try {
      // Convert the stream to a Future to get initial data
      final pets = await _databaseService
          .getUserPets(widget.user.id)
          .first;
      if (mounted) {
        setState(() {
          _userPets = pets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pets: $e')),
        );
      }
    }
  }

  Future<void> _checkFollowStatus() async {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return;

    final isFollowing = await _databaseService.isFollowing(
      currentUser.id,
      widget.user.id,
    );
    if (mounted) {
      setState(() => _isFollowing = isFollowing);
    }
  }

  Future<void> _toggleFollow() async {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return;

    setState(() => _isLoadingFollow = true);
    try {
      if (_isFollowing) {
        await _databaseService.unfollowUser(currentUser.id, widget.user.id);
      } else {
        await _databaseService.followUser(currentUser.id, widget.user.id);
      }
      if (mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
          _isLoadingFollow = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFollow = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildPetCard(Pet pet) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: pet.imageUrls.isNotEmpty
            ? CircleAvatar(
                backgroundImage: NetworkImage(pet.imageUrls.first),
              )
            : CircleAvatar(
                child: Text(pet.name[0].toUpperCase()),
              ),
        title: Text(pet.name),
        subtitle: Text('${pet.breed} • ${pet.age} years old'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser;
    final isCurrentUser = currentUser?.id == widget.user.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCurrentUser ? 'Your Profile' : 'User Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.user.photoURL != null
                        ? NetworkImage(widget.user.photoURL!)
                        : null,
                    child: widget.user.photoURL == null
                        ? Text(
                            widget.user.displayName?[0].toUpperCase() ??
                                widget.user.email[0].toUpperCase(),
                            style: const TextStyle(fontSize: 32),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.user.displayName ?? 'No name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.user.username != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '@${widget.user.username}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Followers count row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${widget.user.followersCount}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Followers',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 32),
                      Column(
                        children: [
                          Text(
                            '${widget.user.followingCount}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Following',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!isCurrentUser && currentUser != null)
                    SizedBox(
                      width: 200,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _isLoadingFollow ? null : _toggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFollowing ? Colors.grey[200] : const Color(0xFFFF9E42),
                          foregroundColor: _isFollowing ? Colors.black87 : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isLoadingFollow
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9E42)),
                                ),
                              )
                            : Text(
                                _isFollowing ? 'Following' : 'Follow',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    )
                  else if (isCurrentUser)
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to edit profile page
                      },
                      child: const Text('Edit Profile'),
                    ),
                ],
              ),
            ),
            const Divider(),
            // Pets section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCurrentUser ? 'Your Pets' : 'User\'s Pets',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const Center(child: SpinningLoader(color: Colors.orange))
                  else if (_userPets.isEmpty)
                    Center(
                      child: Text(
                        isCurrentUser
                            ? 'You haven\'t added any pets yet'
                            : 'This user hasn\'t added any pets yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _userPets.map(_buildPetCard).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 