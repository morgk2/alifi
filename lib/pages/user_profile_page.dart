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
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          (user.displayName != null && user.displayName!.isNotEmpty)
              ? user.displayName!
              : (user.username != null && user.username!.isNotEmpty ? user.username! : 'Profile'),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 0),
              padding: const EdgeInsets.symmetric(vertical: 32),
              color: Colors.white,
              child: Column(
                children: [
                  if (user.photoURL != null && user.photoURL!.isNotEmpty)
                  CircleAvatar(
                      radius: 54,
                      backgroundImage: NetworkImage(user.photoURL!),
                    )
                  else
                    const CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 54, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user.username != null && user.username!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '@${user.username!}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Stats row
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                (user.petsRescued).toString(),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          _ProfileStatDivider(),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                (user.followersCount).toString(),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          _ProfileStatDivider(),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                (user.level).toString(),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                'Pets\nRescued',
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          _ProfileStatDivider(),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                'Followers',
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          _ProfileStatDivider(),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                'Level',
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!isCurrentUser && currentUser != null)
                    OutlinedButton(
                        onPressed: _isLoadingFollow ? null : _toggleFollow,
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        side: BorderSide(color: _isFollowing ? Colors.grey : const Color(0xFFFFB300)),
                        foregroundColor: _isFollowing ? Colors.grey : const Color(0xFFFFB300),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        backgroundColor: _isFollowing ? Colors.grey[100] : Colors.white,
                        ),
                        child: _isLoadingFollow
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                                ),
                              )
                            : Text(
                                _isFollowing ? 'Following' : 'Follow',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                ],
              ),
            ),
            // Achievements
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: const [
                        Icon(Icons.emoji_events, size: 24, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Achievements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Achievement>>(
                    future: _fetchAchievements(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: SpinningLoader(color: Colors.orange));
                      }
                      final achievements = snapshot.data ?? [];
                      return SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: achievements.length,
                          itemBuilder: (context, index) {
                            return _AchievementBadge(achievement: achievements[index]);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Owned pets
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 32),
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: const [
                        Icon(Icons.pets, size: 22, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Owned pets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: SpinningLoader(color: Colors.orange))
                      : _userPets.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text('No pets found.', style: TextStyle(color: Colors.grey)),
                            )
                          : SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _userPets.length,
                                itemBuilder: (context, index) {
                                  final pet = _userPets[index];
                                  return Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        pet.imageUrls.isNotEmpty
                                            ? CircleAvatar(
                                                radius: 32,
                                                backgroundImage: NetworkImage(pet.imageUrls.first),
                                              )
                                            : const CircleAvatar(
                                                radius: 32,
                                                backgroundColor: Colors.grey,
                                                child: Icon(Icons.pets, color: Colors.white),
                                              ),
                                        const SizedBox(height: 8),
                                        Text(
                                          pet.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          pet.breed,
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dummy data for achievements and activities (replace with real data as needed)
  Future<List<Achievement>> _fetchAchievements() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const Achievement(
        title: 'First Reunion',
        description: 'Helped reunite your first pet with its owner',
        icon: Icons.emoji_emotions,
      ),
      const Achievement(
        title: 'Guardian Angel',
        description: 'Helped rescue pets 3 days in a row',
        icon: Icons.pets,
      ),
      const Achievement(
        title: 'Neighborhood Hero',
        description: '3 confirmed rescues in same location',
        icon: Icons.star,
      ),
    ];
  }

  Future<List<Activity>> _fetchActivities() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const Activity(
        text: 'Rescued a pet',
        time: '23 hours ago',
        icon: Icons.volunteer_activism,
      ),
      const Activity(
        text: 'Donated',
        time: '2 days ago',
        icon: Icons.attach_money,
      ),
      const Activity(
        text: 'Bought accessory',
        time: 'a week ago',
        icon: Icons.shopping_cart,
      ),
    ];
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final int value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }
}

class _ProfileStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      width: 1.5,
      height: 32,
      color: Colors.grey[300],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 150,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.amber[50],
            child: Icon(achievement.icon, size: 32, color: Colors.amber[800]),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(activity.icon, size: 28, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text(
          activity.text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          activity.time,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;

  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class Activity {
  final String text;
  final String time;
  final IconData icon;

  const Activity({
    required this.text,
    required this.time,
    required this.icon,
  });
} 