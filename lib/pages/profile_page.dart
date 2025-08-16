import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'edit_profile_page.dart';
import '../services/database_service.dart';
import '../widgets/spinning_loader.dart';
import '../models/pet.dart';
import '../models/store_product.dart';
import '../widgets/verification_badge.dart';
import '../widgets/reviews_section.dart';
import '../widgets/profile_skeleton_loader.dart';
import 'product_details_page.dart';

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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        
        final pets = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];
            return Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: pet.photoURL != null && pet.photoURL!.isNotEmpty
                      ? NetworkImage(pet.photoURL!)
                      : null,
                  child: pet.photoURL == null || pet.photoURL!.isEmpty
                      ? const Icon(Icons.pets, size: 35)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProductsGrid(User user) {
    return StreamBuilder<List<StoreProduct>>(
      stream: DatabaseService().getStoreProducts(storeId: user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SpinningLoader());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No products yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        final products = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return GestureDetector(
              onTap: () {
                // Navigate to product details page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsPage(product: product),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: product.imageUrls.isNotEmpty
                            ? Image.network(
                                product.imageUrls.first,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported, size: 50),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your profile')),
      );
    }

    final isVet = user.accountType == 'vet';
    final isStore = user.accountType == 'store';

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          user.displayName ?? '',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // Show menu options
            },
          ),
        ],
      ),
      body: Column(
                children: [
          // Top profile section with TikTok-style layout
                  Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                // Profile picture and verification
                        Stack(
                          children: [
                            if (user.photoURL != null && user.photoURL!.isNotEmpty)
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(user.photoURL!),
                              )
                            else
                              const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, size: 50, color: Colors.white),
                              ),
                    if (user.isVerified ?? false)
                              Positioned(
                        bottom: 0,
                                right: 0,
                                child: ProfileVerificationBadge(
                                  size: 24,
                                  backgroundColor: Colors.white,
                                  iconColor: const Color(0xFF1DA1F2),
                                ),
                              ),
                          ],
                        ),
                const SizedBox(height: 16),
                        
                // Display name
                        Text(
                          user.displayName ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                // Compact stats row (TikTok-style)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // First stat
                    if (isVet) ...[
                      _buildCompactStat(
                        (user.patients?.length ?? 0).toString(),
                        'Patients',
                      ),
                      _buildCompactDivider(),
                      _buildCompactStat(
                        (user.followersCount ?? 0).toString(),
                        'Followers',
                      ),
                      _buildCompactDivider(),
                      _buildCompactStat(
                        (user.rating ?? 0.0).toStringAsFixed(1),
                        'Rating',
                      ),
                    ] else if (isStore) ...[
                      _buildCompactStat(
                        (user.totalOrders ?? 0).toString(),
                        'Orders',
                      ),
                      _buildCompactDivider(),
                      _buildCompactStat(
                        (user.followersCount ?? 0).toString(),
                        'Followers',
                      ),
                      _buildCompactDivider(),
                            _buildCompactStat(
                        (user.rating ?? 0.0).toStringAsFixed(1),
                        'Rating',
                      ),
                    ] else ...[
                      StreamBuilder<List<Pet>>(
                        stream: DatabaseService().getUserPets(user.id),
                        builder: (context, snapshot) {
                          final count = snapshot.data?.length ?? 0;
                          return _buildCompactStat(count.toString(), 'Pets');
                        },
                            ),
                            _buildCompactDivider(),
                            _buildCompactStat(
                              (user.followersCount ?? 0).toString(),
                              'Followers',
                            ),
                            _buildCompactDivider(),
                            _buildPetsRescuedStat(
                              (user.petsRescued ?? 0).toString(),
                            ),
                    ],
                          ],
                        ),
                        
                // Bio section (TikTok-style, between stats and buttons)
                        if (user.basicInfo != null && user.basicInfo!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                              user.basicInfo!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                ],
                
                const SizedBox(height: 20),
                
                                // Action buttons with fixed width
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      text: 'Edit profile',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfilePage(),
                                ),
                              );
                            },
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      text: 'Sign out',
                      onPressed: () => _handleSignOut(context),
                    ),
                  ],
                ),
                      ],
                    ),
                  ),
                  
                            // TikTok-style tabs with custom indicator
                  Container(
            color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.black,
                      indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
              splashFactory: NoSplash.splashFactory,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
                      tabs: [
                Tab(text: isVet ? 'Patients' : (isStore ? 'Products' : 'Activity')),
                const Tab(text: 'Reviews'),
                      ],
                    ),
                  ),
                  
          // Tab content
                  Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // First tab content
                Container(
                  color: Colors.grey[50],
                  padding: const EdgeInsets.all(16),
                  child: isVet
                      ? _buildPatientsList(user.patients ?? [])
                      : isStore
                          ? _buildProductsGrid(user)
                          : FutureBuilder<List<Achievement>>(
                              future: _fetchAchievements(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: SpinningLoader());
                                }
                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(child: Text('No achievements yet'));
                                }
                                return ListView.builder(
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
                ),
                
                // Reviews tab
                Container(
                  color: Colors.grey[50],
                  child: ReviewsTabView(
                    userId: user.id,
                    userType: user.accountType ?? 'user',
                  ),
                ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

    Widget _buildCompactStat(String value, String label) {
    return Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      );
  }

  Widget _buildPetsRescuedStat(String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0), // Move entire column down
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Pets',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 1),
          const Text(
            'Rescued',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDivider() {
    return Container(
      width: 1,
      height: 20,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 120, // Fixed width
      height: 40, // Fixed height
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.black.withOpacity(0.05);
              }
              if (states.contains(MaterialState.pressed)) {
                return Colors.black.withOpacity(0.1);
              }
              return null;
            },
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
              fontSize: 14,
          ),
        ),
      ),
    );
  }
}

