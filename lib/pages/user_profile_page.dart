import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/pet.dart';
import '../models/store_product.dart';
import '../services/database_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/spinning_loader.dart';
import '../widgets/verification_badge.dart';
import 'store/manage_store_products_page.dart';
import 'vet_chat_page.dart';

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
  late Stream<User?> _userStream;

  @override
  void initState() {
    super.initState();
    _loadUserPets();
    _checkFollowStatus();
    _userStream = _databaseService.getUserStream(widget.user.id);
  }

  Future<void> _loadUserPets() async {
    try {
      if (!mounted) return;
      
      // Subscribe to the pets stream
      _databaseService
          .getUserPets(widget.user.id)
          .listen((pets) {
      if (mounted) {
        setState(() {
          _userPets = pets;
          _isLoading = false;
        });
      }
          },
          onError: (e) {
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading pets: $e')),
              );
            }
          });
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

    try {
    final isFollowing = await _databaseService.isFollowing(
      currentUser.id,
      widget.user.id,
    );
    if (mounted) {
      setState(() => _isFollowing = isFollowing);
      }
    } catch (e) {
      print('Error checking follow status: $e');
      // Don't show error to user as this is not critical
    }
  }

  Future<void> _toggleFollow() async {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to follow users')),
      );
      return;
    }

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
          SnackBar(content: Text('Error: ${e.toString()}')),
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

  Widget _buildStoreProducts(User user) {
    return StreamBuilder<List<StoreProduct>>(
      stream: _databaseService.getStoreProducts(
        storeId: user.id,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: SpinningLoader(color: Colors.orange),
            ),
          );
        }

        final user = snapshot.data!;
    final currentUser = context.read<AuthService>().currentUser;
        final isCurrentUser = currentUser?.id == user.id;
        final isVet = user.accountType == 'vet';
        final isStore = user.accountType == 'store';
        final buttonColor = isVet ? Colors.blue : (isStore ? Colors.green : Colors.orange);

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.displayName ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 8),
                        const VerificationBadge(size: 20),
                      ],
                    ],
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
                              if (isVet) ...[
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      (user.patients?.length ?? 0).toString(),
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
                                      (user.followersCount ?? 0).toString(),
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
                                      (user.rating ?? 0.0).toStringAsFixed(1),
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
                                      (user.totalOrders ?? 0).toString(),
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
                                      (user.followersCount ?? 0).toString(),
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
                                      (user.rating ?? 0.0).toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ] else ...[
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                      (user.pets?.length ?? 0).toString(),
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
                                      (user.followers.length).toString(),
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
                                      (user.rating ?? 0.0).toStringAsFixed(1),
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
                  const SizedBox(height: 16),
                  if (!isCurrentUser) ...[
                    // Action buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Follow button
                        OutlinedButton(
                          onPressed: _isLoadingFollow ? null : _toggleFollow,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _isFollowing ? Colors.white : buttonColor,
                            foregroundColor: _isFollowing ? buttonColor : Colors.white,
                            side: BorderSide(
                              color: _isFollowing ? buttonColor : Colors.transparent,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            elevation: 0,
                          ),
                          child: _isLoadingFollow
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _isFollowing ? buttonColor : Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  _isFollowing ? 'Following' : 'Follow',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                        // Contact button for vets
                        if (isVet) ...[
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VetChatPage(vetUser: user),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.grey[700],
                              side: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Contact',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
                if (isVet && user.patients != null) ...[
                  // Basic Info section for vets
            Container(
              width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          user.basicInfo ?? 'No basic info provided',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Patients section for vets
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          'Patients',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (user.patients!.isNotEmpty)
                          FutureBuilder<List<Pet>>(
                            future: DatabaseService().getPets(user.patients!),
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
                          ),
                      ],
                    ),
                  ),
                ] else if (isStore) ...[
                  // Basic Info section for stores
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          user.basicInfo ?? 'No basic info provided',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Products section for stores
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            if (isCurrentUser)
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
                        _buildStoreProducts(user),
                      ],
                    ),
                  ),
                ] else ...[
                  // Original pets section for non-vet users
                  StreamBuilder<List<Pet>>(
                    stream: _databaseService.getUserPets(user.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: SpinningLoader());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No pets found'),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) => _buildPetCard(snapshot.data![index]),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          floatingActionButton: isCurrentUser && isStore
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageStoreProductsPage(),
                      ),
                    );
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
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