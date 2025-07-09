import 'package:flutter/material.dart';
import '../widgets/placeholder_image.dart';
import 'edit_profile_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Slightly darker gray background
      body: SafeArea(
        child: Column(
          children: [
            // White section (header, profile, stats)
            Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  // Header with back and flag buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.flag_outlined),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  // Empty header for safe space
                  const SizedBox(height: 8),
                  // Profile content container
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile image
                        const PlaceholderImage(
                          width: 120,
                          height: 120,
                          isCircular: true,
                        ),
                        const SizedBox(height: 16),
                        // Username
                        const Text(
                          '@username',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Edit profile button
                        SizedBox(
                          height: 36,
                          width: 120,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfilePage(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                color: Color(0xFFFF9E42),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF9E42),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Stats row - centered
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _buildStatColumn('0', 'Pets Rescued'),
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.grey[300],
                                margin: const EdgeInsets.symmetric(horizontal: 32),
                              ),
                              Expanded(
                                child: _buildStatColumn('0', 'Followers'),
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.grey[300],
                                margin: const EdgeInsets.symmetric(horizontal: 32),
                              ),
                              Expanded(
                                child: _buildStatColumn('0', 'Level'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Gray section (achievements and activities)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Slightly darker gray
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Achievements section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Achievements title with icon
                            Row(
                              children: [
                                const Icon(
                                  Icons.emoji_events_outlined,
                                  size: 24,
                                  color: Color(0xFFFF9E42),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Achievements',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Achievements container
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: FutureBuilder<List<Achievement>>(
                                future: _fetchAchievements(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(24),
                                        child: Text('No achievements yet'),
                                      ),
                                    );
                                  }
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: snapshot.data!
                                        .map((achievement) => _buildAchievementCard(
                                              achievement.title,
                                              achievement.description,
                                            ))
                                        .toList(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Last activities section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Activities title with icon
                            Row(
                              children: [
                                const Icon(
                                  Icons.history_outlined,
                                  size: 24,
                                  color: Color(0xFFFF9E42),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Last Activities',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Activities container
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: FutureBuilder<List<Activity>>(
                                future: _fetchActivities(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(24),
                                        child: Text('No activities yet'),
                                      ),
                                    );
                                  }
                                  return Column(
                                    children: snapshot.data!
                                        .map((activity) => _buildActivityItem(
                                              activity.text,
                                              activity.time,
                                            ))
                                        .toList(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(String title, String description) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFF9E42),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pets,
              color: Color(0xFFFF9E42),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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
