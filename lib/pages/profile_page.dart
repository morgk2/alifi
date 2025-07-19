import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/placeholder_image.dart';
import '../services/auth_service.dart';
import 'edit_profile_page.dart';
import '../services/database_service.dart'; // Added import for DatabaseService
// Added import for UserSearchPage
import '../widgets/spinning_loader.dart';
import '../models/pet.dart'; // Added import for Pet model

// Models for database-driven content
class Achievement {
  final String title;
  final String description;
  final IconData icon;

  const Achievement({
    required this.title,
    required this.description,
    this.icon = Icons.emoji_events,
  });
}

class Activity {
  final String text;
  final String time;
  final IconData icon;

  const Activity({
    required this.text,
    required this.time,
    this.icon = Icons.pets,
  });
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // These would be fetched from the database in a real app
  Future<List<Achievement>> _fetchAchievements() async {
    // Simulating a database call
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const Achievement(
        title: 'First Reunion',
        description: 'Helped reunite a lost pet with their family',
      ),
      const Achievement(
        title: 'Guardian Angel',
        description: 'Rescued 5 pets in your area',
      ),
      const Achievement(
        title: 'Neighborhood Hero',
        description: 'Most active user in your neighborhood',
      ),
    ];
  }

  // These would be fetched from the database in a real app
  Future<List<Activity>> _fetchActivities() async {
    // Simulating a database call
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const Activity(
        text: 'Reported a missing cat in Downtown',
        time: '2 days ago',
      ),
      const Activity(
        text: 'Helped find Luna the dog',
        time: '5 days ago',
      ),
      const Activity(
        text: 'Donated to "Help Street Cats"',
        time: '1 week ago',
      ),
    ];
  }

  void _handleSignOut(BuildContext context) async {
    final authService = context.read<AuthService>();
    await authService.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final user = authService.currentUser;
        final isAuthenticated = authService.isAuthenticated;
        final isCurrentUser = true; // This page is only for the current user in this app

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              if (isAuthenticated)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  },
                ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.black),
                onPressed: () => _handleSignOut(context),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if (user != null) {
                final dbService = DatabaseService();
                final freshUser = await dbService.getUser(user.id);
                if (freshUser != null) {
                  authService.updateCurrentUser(freshUser);
                }
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                        if (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                        CircleAvatar(
                            radius: 54,
                          backgroundImage: NetworkImage(user!.photoURL!),
                        )
                      else
                          const CircleAvatar(
                            radius: 54,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, size: 54, color: Colors.white),
                        ),
                      const SizedBox(height: 16),
                      Text(
                          user?.displayName ?? '',
                        style: const TextStyle(
                            fontSize: 24,
                          fontWeight: FontWeight.bold,
                          ),
                        ),
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
                                      (user?.petsRescued ?? 0).toString(),
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
                                      (user?.followersCount ?? 0).toString(),
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
                                      (user?.level ?? 1).toString(),
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
                        if (isCurrentUser)
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfilePage(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              side: const BorderSide(color: Color(0xFFFFB300)),
                              foregroundColor: const Color(0xFFFFB300),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                            child: const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                children: achievements.map((achievement) => _AchievementBadge(achievement: achievement)).toList(),
                              ),
                            );
                          },
                                                ),
                                              ],
                                            ),
                                          ),
                  // Pets Owned (replace Last activities)
                  FutureBuilder<List<Pet>>(
                    future: DatabaseService().getUserPets(user!.id).first,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: SpinningLoader(color: Colors.orange));
                          }
                      final pets = snapshot.data ?? [];
                      return Container(
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
                            pets.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 24),
                                    child: Text('No pets found.', style: TextStyle(color: Colors.grey)),
                                  )
                                : SizedBox(
                                    height: 120,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      itemCount: pets.length,
                                      itemBuilder: (context, index) {
                                        final pet = pets[index];
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
                      );
                    },
                ),
              ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final int value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12), // Increased space between number and label
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ProfileStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.5,
      height: 36,
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
