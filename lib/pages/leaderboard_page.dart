import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'user_profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/spinning_loader.dart';
import '../widgets/verification_badge.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  void _navigateToUserProfile(BuildContext context, User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(user: user),
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context, User user, {double size = 80, Color? borderColor}) {
    return GestureDetector(
      onTap: () => _navigateToUserProfile(context, user),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderColor != null ? Border.all(color: borderColor, width: 3) : null,
        ),
        child: ClipOval(
          child: user.photoURL != null
              ? CachedNetworkImage(
                  imageUrl: user.photoURL!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildDefaultAvatar(size: size),
                  errorWidget: (context, url, error) => _buildDefaultAvatar(size: size),
                  fadeInDuration: const Duration(milliseconds: 300),
                )
              : _buildDefaultAvatar(size: size),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar({required double size}) {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildTopPosition(BuildContext context, User user, int position, double height) {
    final colors = {
      1: const Color(0xFFFFD700), // Gold
      2: const Color(0xFFC0C0C0), // Silver
      3: const Color(0xFFCD7F32), // Bronze
    };

    return GestureDetector(
      onTap: () => _navigateToUserProfile(context, user),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProfilePicture(
            context,
            user,
            size: position == 1 ? 100 : 80,
            borderColor: colors[position],
          ),
          const SizedBox(height: 8),
          Text(
            '#$position',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors[position],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.displayName ?? 'User',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (user.isVerified) ...[
                const SizedBox(width: 4),
                const VerificationBadge(size: 16),
              ],
            ],
          ),
          Text(
            'Level ${user.level}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${user.petsRescued} rescued',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListItem(BuildContext context, User user, int position, bool isCurrentUser) {
    return GestureDetector(
      onTap: () => _navigateToUserProfile(context, user),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.orange.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentUser ? Colors.orange.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Position Number
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                position.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // User Avatar
            _buildProfilePicture(context, user, size: 48),
            const SizedBox(width: 16),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Pets rescued: ${user.petsRescued}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Level ${user.level}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 8),
                        const VerificationBadge(size: 16),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

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
          'Leaderboard',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Section with Trophy Icon
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/leaderboard_3d.png',
                  height: 80,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          // Leaderboard List
          Expanded(
            child: StreamBuilder<List<User>>(
              stream: databaseService.getLeaderboardUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: SpinningLoader(
                      size: 40,
                      color: Colors.orange,
                    ),
                  );
                }

                final users = snapshot.data!;
                final topThree = users.take(3).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return RepaintBoundary(
                      child: _buildUserListItem(context, users[index], index + 1, currentUser?.id == users[index].id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 