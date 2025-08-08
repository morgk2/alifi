import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/local_storage_service.dart';
import '../services/navigation_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../pages/user_profile_page.dart';
import '../widgets/spinning_loader.dart';
import '../widgets/verification_badge.dart';
import '../widgets/skeleton_loader.dart';
import 'dart:ui';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _databaseService = DatabaseService();
  final _localStorageService = LocalStorageService();
  List<User> _searchResults = [];
  List<User> _recentProfiles = [];
  List<User> _recommendedVetsAndStores = [];
  bool _isLoading = false;
  bool _isSearching = false;
  
  // Animation controller for fade effect
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _loadRecentProfiles();
    _loadRecommendedVetsAndStores();
    
    // Start with recommendations visible
    _fadeController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentProfiles() async {
    final profiles = await _localStorageService.getRecentProfiles();
    setState(() => _recentProfiles = profiles);
  }

  Future<void> _loadRecommendedVetsAndStores() async {
    try {
      final vetsAndStores = await _databaseService.getRandomVetsAndStores(limit: 10);
      if (mounted) {
        setState(() => _recommendedVetsAndStores = vetsAndStores);
      }
    } catch (e) {
      print('Error loading recommended vets and stores: $e');
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      _fadeController.forward(); // Fade in recommendations
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
    });
    _fadeController.reverse(); // Fade out recommendations

    try {
      final users = await _databaseService.searchUsers(
        displayName: query,
        username: query,
        email: query,
      );
      if (mounted) {
        setState(() {
          _searchResults = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching users: $e')),
        );
      }
    }
  }

  void _viewUserProfile(BuildContext context, User user) async {
    // Add to recent profiles before navigating
    await _localStorageService.addRecentProfile(user);
    // Reload recent profiles immediately to show the change
    await _loadRecentProfiles();
    
    if (mounted) {
      await NavigationService.push(
        context,
        UserProfilePage(user: user),
      );
      
      // Reload recent profiles again when returning from profile page
      await _loadRecentProfiles();
    }
  }

  Widget _buildAccountCard(User user) {
    final isVet = user.accountType == 'vet';
    final isStore = user.accountType == 'store';

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => _viewUserProfile(context, user),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar with verification badge
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        image: user.photoURL != null
                            ? DecorationImage(
                                image: NetworkImage(user.photoURL!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user.photoURL == null
                          ? Center(
                              child: Text(
                                user.displayName?[0].toUpperCase() ?? user.email[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : null,
                    ),
                    // Verification badge
                    if (user.isVerified)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: ProfileVerificationBadge(
                          size: 18,
                          backgroundColor: Colors.white,
                          iconColor: const Color(0xFF1DA1F2),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Name
                Text(
                  user.displayName ?? 'No name',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Account type badge and rating (moved up)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Account type badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isVet ? Colors.blue[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isVet ? Colors.blue[200]! : Colors.green[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVet ? Icons.medical_services_rounded : Icons.store_rounded,
                            size: 12,
                            color: isVet ? Colors.blue[600] : Colors.green[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isVet ? 'Vet' : 'Store',
                            style: TextStyle(
                              color: isVet ? Colors.blue[600] : Colors.green[600],
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Rating
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.orange[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Basic info under name (moved down)
                if (user.basicInfo != null && user.basicInfo!.isNotEmpty)
                  Text(
                    user.basicInfo!.length > 80 
                        ? '${user.basicInfo!.substring(0, 80)}...'
                        : user.basicInfo!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCardSkeleton() {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar skeleton (circular)
            ShimmerLoader(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.25),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Name skeleton
            ShimmerLoader(
              child: Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Account type badge and rating skeleton (in one row)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Account type badge skeleton
                ShimmerLoader(
                  child: Container(
                    width: 50,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Rating skeleton
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Colors.grey.withOpacity(0.25),
                    ),
                    const SizedBox(width: 4),
                    ShimmerLoader(
                      child: Container(
                        width: 30,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Basic info skeleton (2 lines)
            Column(
              children: [
                ShimmerLoader(
                  child: Container(
                    width: 160,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ShimmerLoader(
                  child: Container(
                    width: 140,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(User user) {
    final currentUser = context.read<AuthService>().currentUser;
    final isCurrentUser = currentUser?.id == user.id;
    final isVet = user.accountType == 'vet';
    final isStore = user.accountType == 'store';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _viewUserProfile(context, user),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                                 // Avatar with verification badge
                 Stack(
                   children: [
                     Container(
                       width: 60,
                       height: 60,
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         color: Colors.grey[200],
                         image: user.photoURL != null
                             ? DecorationImage(
                                 image: NetworkImage(user.photoURL!),
                                 fit: BoxFit.cover,
                               )
                             : null,
                       ),
                       child: user.photoURL == null
                           ? Center(
                               child: Text(
                                 user.displayName?[0].toUpperCase() ?? user.email[0].toUpperCase(),
                                 style: TextStyle(
                                   color: Colors.grey[600],
                                   fontSize: 20,
                                   fontWeight: FontWeight.w600,
                                 ),
                               ),
                             )
                           : null,
                     ),
                     // Verification badge positioned on top-right
                     if (user.isVerified)
                       Positioned(
                         top: 0,
                         right: 0,
                         child: ProfileVerificationBadge(
                           size: 20,
                           backgroundColor: Colors.white,
                           iconColor: const Color(0xFF1DA1F2),
                         ),
                       ),
                   ],
                 ),
                
                const SizedBox(width: 16),
                
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                             // Name
                       Text(
                         user.displayName ?? 'No name',
                         style: const TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.w700,
                         ),
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       ),
                      
                      const SizedBox(height: 4),
                      
                      // Username/email
                      Text(
                        user.username ?? user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Account type badges and info
                      Row(
                        children: [
                          if (isVet)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.medical_services_rounded,
                                    size: 14,
                                    color: Colors.blue[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Vet',
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (isStore)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.store_rounded,
                                    size: 14,
                                    color: Colors.green[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Store',
                                    style: TextStyle(
                                      color: Colors.green[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          if (isCurrentUser) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_rounded,
                                    size: 14,
                                    color: Color(0xFFF59E0B),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'You',
                                    style: TextStyle(
                                      color: Color(0xFFF59E0B),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      // Additional info for vets and stores
                      if ((isVet || isStore) && user.basicInfo != null && user.basicInfo!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          user.basicInfo!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      // Store ratings
                      if (isStore) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Colors.orange[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.shopping_cart_rounded,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${user.totalOrders} orders',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Arrow icon
                if (!isCurrentUser)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title only
                  const Text(
                    'Search',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _searchUsers,
                      decoration: InputDecoration(
                        hintText: 'Search people, pets, vets...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.search_rounded,
                            color: Colors.grey[600],
                            size: 22,
                          ),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    _searchUsers('');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.grey[600],
                                      size: 16,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content area
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinningLoader(color: Color(0xFFF59E0B)),
                          SizedBox(height: 16),
                          Text(
                            'Searching...',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        if (!_isSearching) ...[
                          // Recommendations section
                          SliverToBoxAdapter(
                            child: AnimatedBuilder(
                              animation: _fadeAnimation,
                              builder: (context, child) {
                                if (_fadeAnimation.value <= 0.0) {
                                  return const SizedBox.shrink();
                                }
                                return Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Recommendations section header
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.recommend_rounded,
                                                color: Colors.purple[600],
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Recommended Vets & Stores',
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                                                             // Horizontal slider
                                       if (_recommendedVetsAndStores.isNotEmpty)
                                         SizedBox(
                                           height: 220,
                                           child: ListView.builder(
                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                            scrollDirection: Axis.horizontal,
                                            itemCount: _recommendedVetsAndStores.length,
                                            itemBuilder: (context, index) {
                                              return _buildAccountCard(_recommendedVetsAndStores[index]);
                                            },
                                          ),
                                        )
                                      else
                                        SizedBox(
                                          height: 220,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                            itemCount: 3, // Show 3 skeleton cards
                                            itemBuilder: (context, index) {
                                              return _buildAccountCardSkeleton();
                                            },
                                          ),
                                        ),
                                      
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Recent section header
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            sliver: SliverToBoxAdapter(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.history_rounded,
                                      color: Color(0xFFF59E0B),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Recent Searches',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Recent profiles or empty state
                          if (_recentProfiles.isEmpty)
                            const SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No recent searches',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Your recent profile visits will appear here',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildUserCard(_recentProfiles[index]),
                                  childCount: _recentProfiles.length,
                                ),
                              ),
                            ),
                        ] else if (_searchResults.isEmpty)
                          const SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No results found',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Try searching with different keywords',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildUserCard(_searchResults[index]),
                                childCount: _searchResults.length,
                              ),
                            ),
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