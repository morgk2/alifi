import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/placeholder_image.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'edit_profile_page.dart';
import '../services/database_service.dart';
import '../widgets/spinning_loader.dart';
import '../models/pet.dart';
import '../models/store_product.dart';
import '../widgets/verification_badge.dart';
import 'store/manage_store_products_page.dart';
import 'admin/admin_dashboard_page.dart';

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

  Widget _buildPatientsList(List<String> patients) {
    return FutureBuilder<List<Pet>>(
      future: DatabaseService().getPets(patients),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SpinningLoader());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No patients found');
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final pet = snapshot.data![index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: pet.photoURL != null
                    ? NetworkImage(pet.photoURL!)
                    : null,
                child: pet.photoURL == null
                    ? const Icon(Icons.pets)
                    : null,
              ),
              title: Text(pet.name),
              subtitle: Text(pet.breed),
            );
          },
        );
      },
    );
  }

  Widget _buildPetsCount(User? user) {
    final petsCount = user?.pets?.length ?? 0;
    return Text(
      petsCount.toString(),
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final user = authService.currentUser;
        final isAuthenticated = authService.isAuthenticated;
        final isCurrentUser = true;
        final isVet = user?.accountType == 'vet';
        final isStore = user?.accountType == 'store';
        final isAdmin = user?.isAdmin ?? false;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              if (isAuthenticated && isAdmin)
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminDashboardPage(),
                      ),
                    );
                  },
                ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user?.displayName ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (user?.isVerified ?? false) ...[
                            const SizedBox(width: 8),
                            const VerificationBadge(size: 20),
                          ],
                        ],
                      ),
                        const SizedBox(height: 16),
                        // Stats row
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (isVet) ...[
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        (user?.patients?.length ?? 0).toString(),
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
                                        (user?.rating ?? 0.0).toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ] else if (isStore) ...[
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        (user?.totalOrders ?? 0).toString(),
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
                                        (user?.rating ?? 0.0).toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.center,
                                      child: _buildPetsCount(user),
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
                                        (user?.rating ?? 0.0).toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                ],
                              ],
                            ),
                        const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isVet) ...[
                                  const Expanded(
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        'Patients',
                                        style: TextStyle(fontSize: 13, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  _ProfileStatDivider(),
                                  const Expanded(
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        'Followers',
                                        style: TextStyle(fontSize: 13, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  _ProfileStatDivider(),
                                  const Expanded(
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        'Rating',
                                        style: TextStyle(fontSize: 13, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ] else if (isStore) ...[
                                  const Expanded(
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        'Total\nOrders',
                                        style: TextStyle(fontSize: 13, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  _ProfileStatDivider(),
                                  const Expanded(
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        'Followers',
                                        style: TextStyle(fontSize: 13, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  _ProfileStatDivider(),
                                  const Expanded(
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        'Rating',
                                        style: TextStyle(fontSize: 13, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  const Expanded(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      'Pets',
                                        style: TextStyle(fontSize: 13, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                _ProfileStatDivider(),
                                  const Expanded(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      'Followers',
                                        style: TextStyle(fontSize: 13, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                _ProfileStatDivider(),
                                  const Expanded(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      'Rating',
                                        style: TextStyle(fontSize: 13, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isStore) ...[
                    // Basic Info section for stores
                  Container(
                    width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                          const Text(
                            'Basic Info',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                          Text(
                            user?.basicInfo ?? 'No basic info provided',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                                                ),
                                              ],
                                            ),
                                          ),
                    const SizedBox(height: 16),
                    // Products section for stores
                    Container(
                        width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                            child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                          const Text(
                                'Products',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ManageStoreProductsPage(),
                                    ),
                                  );
                                },
                                child: const Text('Manage'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<List<StoreProduct>>(
                            stream: DatabaseService().getStoreProducts(
                              storeId: user?.id,
                              limit: 5,
                            ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: SpinningLoader());
                                }
                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Text(
                                  'No products yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                );
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                  final product = snapshot.data![index];
                                    return ListTile(
                                    leading: product.imageUrls.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: Image.network(
                                              product.imageUrls.first,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(Icons.image_not_supported),
                                    title: Text(product.name),
                                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.orange[700],
                                        ),
                                        Text(' ${product.rating.toStringAsFixed(1)}'),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.shopping_cart,
                                          size: 16,
                                        ),
                                        Text(' ${product.totalOrders}'),
                                      ],
                                    ),
                                    );
                                  },
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Original achievements section for non-vet users
                    FutureBuilder<List<Achievement>>(
                      future: _fetchAchievements(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: SpinningLoader());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No achievements yet');
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final achievement = snapshot.data![index];
                            return ListTile(
                              leading: Icon(achievement.icon),
                              title: Text(achievement.title),
                              subtitle: Text(achievement.description),
                            );
                          },
                      );
                    },
                ),
                  ],
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
