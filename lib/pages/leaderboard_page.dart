import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  Widget _buildTopPosition(BuildContext context, User user, int position) {
    final colors = {
      1: const Color(0xFFFFD700), // Gold
      2: const Color(0xFFC0C0C0), // Silver
      3: const Color(0xFFCD7F32), // Bronze
    };

    final sizes = {
      1: 100.0, // Reduced size to prevent cropping
      2: 80.0,
      3: 80.0,
    };

    return GestureDetector(
      onTap: () => _navigateToUserProfile(context, user),
      child: Container(
        width: 120, // Fixed width to prevent overflow
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Position crown/medal using Cupertino icons
            Container(
              height: 35,
              child: position == 1 
                ? Icon(CupertinoIcons.star_circle_fill, color: colors[position], size: 32)
                : Icon(CupertinoIcons.star_circle, color: colors[position], size: 28),
            ),
            const SizedBox(height: 12),
            
            // Profile picture with proper spacing
            _buildProfilePicture(
              context,
              user,
              size: sizes[position]!,
              borderColor: colors[position],
            ),
            
            const SizedBox(height: 12),
            
            // Podium base below profile
            Container(
              width: 70,
              height: position == 1 ? 50 : 35,
              decoration: BoxDecoration(
                color: colors[position]?.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                border: Border.all(color: colors[position]!, width: 2),
              ),
              child: Center(
                child: Text(
                  '#$position',
                  style: TextStyle(
                    fontSize: position == 1 ? 18 : 14,
                    fontWeight: FontWeight.bold,
                    color: colors[position],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // User name with verification
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    user.displayName ?? 'User',
                    style: TextStyle(
                      fontSize: position == 1 ? 15 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (user.isVerified) ...[
                  const SizedBox(width: 4),
                  VerificationBadge(size: position == 1 ? 16 : 14),
                ],
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Pets rescued count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.paw, color: Colors.green, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${user.petsRescued}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              'Rescued',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildUserListItem(BuildContext context, User user, int position, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.green.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Position Number
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              position.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // User Avatar
          _buildProfilePicture(context, user, size: 44),
          const SizedBox(width: 12),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.displayName ?? 'User',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: 6),
                      const VerificationBadge(size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(CupertinoIcons.paw, color: Colors.green, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${user.petsRescued} pets rescued',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
          'assets/images/back_icon.png',
          width: 24,
          height: 24,
          color: Colors.black,
        ),
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
      body: StreamBuilder<List<User>>(
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
                color: Colors.green,
              ),
            );
          }

          final users = snapshot.data!;
          final topThree = users.take(3).toList();
          final remainingUsers = users.skip(3).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Header Section with Trophy Icon
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/leaderboard_3d.png',
                        height: 80,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Pet Heroes Leaderboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Top rescuers making a difference',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
              
              // Top 3 Podium Section
              if (topThree.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Second place (left)
                        if (topThree.length > 1)
                          _buildTopPosition(context, topThree[1], 2),
                        
                        // First place (center, higher)
                        if (topThree.isNotEmpty)
                          _buildTopPosition(context, topThree[0], 1),
                        
                        // Third place (right)
                        if (topThree.length > 2)
                          _buildTopPosition(context, topThree[2], 3),
                      ],
                    ),
                  ),
                ),
              
              // Spacing after podium
              if (topThree.isNotEmpty)
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              
              // Other Heroes Header
              if (remainingUsers.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.list_bullet, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Other Heroes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Spacing before list
              if (remainingUsers.isNotEmpty)
                const SliverToBoxAdapter(
                  child: SizedBox(height: 12),
                ),
              
              // Rest of users in sliver list
              if (remainingUsers.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = remainingUsers[index];
                      final position = index + 4; // Starting from 4th position
                      final isCurrentUser = currentUser?.id == user.id;
                      
                      return _buildUserListItem(context, user, position, isCurrentUser);
                    },
                    childCount: remainingUsers.length,
                  ),
                ),
              
              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
              
              // Empty state if no remaining users
              if (remainingUsers.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No other users to display',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
} 