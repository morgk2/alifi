import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/pet.dart';
import '../models/store_product.dart';
import '../services/database_service.dart';
import '../services/navigation_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/spinning_loader.dart';
import '../widgets/verification_badge.dart';
import '../widgets/reviews_section.dart';
import 'vet_chat_page.dart';
import 'product_details_page.dart';

class UserProfilePage extends StatefulWidget {
  final User user;

  const UserProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> with TickerProviderStateMixin {
  final _databaseService = DatabaseService();
  List<Pet> _userPets = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isLoadingFollow = false;
  late Stream<User?> _userStream;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserPets();
    _checkFollowStatus();
    _userStream = _databaseService.getUserStream(widget.user.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          SnackBar(content: Text('Error updating follow status: $e')),
        );
      }
    }
  }

  Future<void> _contactVet() async {
    if (widget.user.accountType != 'vet') return;

    try {
      NavigationService.push(
        context,
        VetChatPage(vetUser: widget.user),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening chat: $e')),
      );
    }
  }

  Widget _buildPatientsList(List<String> patients) {
    return FutureBuilder<List<Pet>>(
      future: _databaseService.getPets(patients),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SpinningLoader());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No patients found',
              style: TextStyle(color: Colors.grey),
            ),
          );
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
      stream: _databaseService.getStoreProducts(storeId: user.id),
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
                NavigationService.push(
                  context,
                  ProductDetailsPage(product: product),
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

  Widget _buildPetsGrid() {
    if (_isLoading) {
      return const Center(child: SpinningLoader());
    }
    
    if (_userPets.isEmpty) {
      return const Center(
        child: Text(
          'No pets yet',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _userPets.length,
      itemBuilder: (context, index) {
        final pet = _userPets[index];
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
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _userStream,
      builder: (context, snapshot) {
        final user = snapshot.data ?? widget.user;
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
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onPressed: () {
                  // Show more options
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
                          _buildCompactStat(
                            _userPets.length.toString(),
                                      'Pets',
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
                          text: _isFollowing ? 'Following' : 'Follow',
                          onPressed: _isLoadingFollow ? null : _toggleFollow,
                          isLoading: _isLoadingFollow,
                          isPrimary: !_isFollowing,
                          isFollowing: _isFollowing,
                          accountType: user.accountType ?? 'user',
                        ),
                          const SizedBox(width: 12),
                        _buildActionButton(
                          text: isVet ? 'Contact' : 'Message',
                          onPressed: isVet ? _contactVet : null,
                          isLoading: false,
                          isPrimary: false,
                          isFollowing: false,
                          accountType: user.accountType ?? 'user',
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
                    Tab(text: isVet ? 'Patients' : (isStore ? 'Products' : 'Pets')),
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
                              : _buildPetsGrid(),
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
      },
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
    required VoidCallback? onPressed,
    required bool isLoading,
    required bool isPrimary,
    required bool isFollowing,
    required String accountType,
  }) {
    // Define colors based on account type
    Color getAccountColor() {
      switch (accountType) {
        case 'vet':
          return Colors.blue;
        case 'store':
          return Colors.green;
        default:
          return Colors.orange;
      }
    }

    final accountColor = getAccountColor();

    return Container(
      width: 120, // Fixed width
      height: 40, // Fixed height
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing && isPrimary ? Colors.white : (isPrimary ? accountColor : Colors.grey[200]),
          foregroundColor: isFollowing && isPrimary ? accountColor : (isPrimary ? Colors.white : Colors.black),
          elevation: 0,
          shadowColor: Colors.transparent,
          side: isFollowing && isPrimary ? BorderSide(color: accountColor, width: 1.5) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return isFollowing && isPrimary ? accountColor.withOpacity(0.1) : Colors.black.withOpacity(0.05);
              }
              if (states.contains(MaterialState.pressed)) {
                return isFollowing && isPrimary ? accountColor.withOpacity(0.2) : Colors.black.withOpacity(0.1);
              }
              return null;
            },
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isFollowing && isPrimary ? accountColor : (isPrimary ? Colors.white : Colors.black),
                  ),
                ),
              )
            : Text(
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