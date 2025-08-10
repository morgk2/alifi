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
import 'discussion_chat_page.dart';
import 'dart:ui';


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
  // Tracks the current height of the SliverAppBar so the profile picture can
  // follow the bottom edge of the banner (and not be blurred with it).
  double _currentAppBarHeight = 0;
  
  // Cache tab content widgets to prevent rebuilding
  Widget? _cachedPatientsWidget;
  Widget? _cachedProductsWidget;
  Widget? _cachedPetsWidget;
  Widget? _cachedReviewsWidget;

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

  // Cached tab content builders
  Widget _getCachedPatientsWidget(User user) {
    _cachedPatientsWidget ??= Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: _buildPatientsList(user.patients ?? []),
    );
    return _cachedPatientsWidget!;
  }

  Widget _getCachedProductsWidget(User user) {
    _cachedProductsWidget ??= Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: _buildProductsGrid(user),
    );
    return _cachedProductsWidget!;
  }

  Widget _getCachedPetsWidget() {
    _cachedPetsWidget ??= Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: _buildPetsGrid(),
    );
    return _cachedPetsWidget!;
  }

  Widget _getCachedReviewsWidget(User user) {
    _cachedReviewsWidget ??= Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: ReviewsTabView(
        userId: user.id,
        userType: user.accountType,
      ),
    );
    return _cachedReviewsWidget!;
  }

  Widget _buildCustomTabBar(bool isVet, bool isStore) {
    final firstTabText = isVet ? 'Patients' : (isStore ? 'Products' : 'Pets');
    const secondTabText = 'Reviews';
    
    // Calculate text widths
    final firstTabWidth = _calculateTextWidth(firstTabText);
    final secondTabWidth = _calculateTextWidth(secondTabText);
    
    return Column(
      children: [
        // Tab buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCustomTab(
              text: firstTabText,
              isSelected: _tabController.index == 0,
              onTap: () {
                _tabController.animateTo(0);
                setState(() {});
              },
            ),
            const SizedBox(width: 40),
            _buildCustomTab(
              text: secondTabText,
              isSelected: _tabController.index == 1,
              onTap: () {
                _tabController.animateTo(1);
                setState(() {});
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Animated sliding indicator
        _buildSlidingIndicator(firstTabWidth, secondTabWidth),
      ],
    );
  }

  Widget _buildCustomTab({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  double _calculateTextWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.size.width;
  }

  Widget _buildSlidingIndicator(double firstTabWidth, double secondTabWidth) {
    final isFirstTab = _tabController.index == 0;
    final indicatorWidth = isFirstTab ? firstTabWidth : secondTabWidth;
    
    // Calculate positions with fine-tuning adjustments
    final totalSpacing = 40.0; // Space between tabs
    final leftAdjustment = -2.0; // Move left tab indicator slightly left
    final rightAdjustment = 2.0; // Move right tab indicator slightly right
    
    final firstTabPosition = 0.0 + leftAdjustment;
    final secondTabPosition = firstTabWidth + totalSpacing + rightAdjustment;
    
    return SizedBox(
      width: firstTabWidth + totalSpacing + secondTabWidth,
      height: 2,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: isFirstTab ? firstTabPosition : secondTabPosition,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: indicatorWidth,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDropdownMenu(BuildContext context, User user) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    final Size buttonSize = button.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx + buttonSize.width - 200, // Right-aligned with button
        buttonPosition.dy, // Start from the top of the button
        buttonPosition.dx + buttonSize.width, // Right edge aligns with button
        buttonPosition.dy + 200, // Allow enough space for menu
      ),
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          child: _buildBlurredDropdownMenu(user),
        ),
      ],
    );
  }

  Widget _buildBlurredDropdownMenu(User user) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdownMenuItem(
                icon: Icons.message_outlined,
                title: 'Send a message',
                onTap: () {
                  Navigator.pop(context);
                  _navigateToChat(user);
                },
              ),
              const Divider(height: 1, color: Colors.black12),
              _buildDropdownMenuItem(
                icon: Icons.report_outlined,
                title: 'Report account',
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog(user);
                },
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
          children: [
              Icon(
                icon,
                size: 22,
                color: isDestructive ? Colors.red : Colors.black87,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : Colors.black87,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToChat(User user) {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to send messages')),
      );
      return;
    }

    NavigationService.push(
      context,
      DiscussionChatPage(storeUser: user),
    );
  }

    String? _selectedReportReason;

  void _showReportDialog(User user) {
    setState(() {
      _selectedReportReason = null; // Reset selection
    });
    
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent, // No background dimming
      builder: (context) => _buildReportDialog(user),
    );
  }

    Widget _buildReportDialog(User user) {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7), // Reduced opacity
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), // Blur inside dialog
                child: Container(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with icon and title
                      Row(
                           children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.report_problem_outlined,
                                color: Colors.red,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                  const Text(
                                    'Report Account',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Help us understand what\'s happening',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[600],
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 32),
                      
                      // User info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100]?.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                                   CircleAvatar(
                              radius: 20,
                              backgroundImage: user.photoURL != null
                                         ? NetworkImage(user.photoURL!)
                                         : null,
                              child: user.photoURL == null
                                  ? const Icon(Icons.person, size: 20)
                                         : null,
                                   ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                user.displayName ?? 'Unknown User',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontFamily: 'Inter',
                                ),
                                       ),
                                     ),
                                 ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Report reasons title
                      const Text(
                        'Why are you reporting this account?',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: 'Inter',
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Scrollable report options
                      Container(
                        height: 280, // Fixed height to make it scrollable
                        child: SingleChildScrollView(
                          child: Column(
                            children: _buildReportOptions(setDialogState),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: Colors.grey[200]?.withOpacity(0.8),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _selectedReportReason != null
                                  ? () {
                                      Navigator.of(context).pop();
                                      _submitReport(user);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey[300],
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Submit Report',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                               ),
                             ),
                           ],
                         ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildReportOptions(StateSetter setDialogState) {
    final reportReasons = [
      'Spam or unwanted content',
      'Inappropriate behavior',
      'Fake or misleading information',
      'Harassment or bullying',
      'Scam or fraud',
      'Hate speech or symbols',
      'Violence or dangerous content',
      'Intellectual property violation',
      'Other',
    ];

    return reportReasons.map((reason) => _buildReportOption(reason, setDialogState)).toList();
  }

  Widget _buildReportOption(String reason, StateSetter setDialogState) {
    final isSelected = _selectedReportReason == reason;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setDialogState(() {
              _selectedReportReason = reason;
            });
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.red.withOpacity(0.1) 
                  : Colors.grey[50]?.withOpacity(0.8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected 
                    ? Colors.red.withOpacity(0.3) 
                    : Colors.grey[300]!.withOpacity(0.6),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected 
                      ? Icons.radio_button_checked 
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.red : Colors.grey[500],
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    reason,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.red[700] : Colors.black87,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitReport(User user) {
    // Implement report submission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report submitted for ${user.displayName ?? 'user'}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildRegularUserProfile(User user, bool isAlifiFavorite) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showDropdownMenu(context, user),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: SpinningLoader())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // Profile Picture
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // White outline
                        CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                            radius: 50,
                          backgroundImage: user.photoURL != null
                                    ? NetworkImage(user.photoURL!)
                                    : null,
                          child: user.photoURL == null
                              ? const Icon(Icons.person, size: 50)
                                    : null,
                              ),
                      ),
                      // Verification badge
                        if (user.isVerified)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: const ProfileVerificationBadge(),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Display Name
                  Text(
                    user.displayName ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCompactStat(
                        _userPets.length.toString(),
                        'Pets',
                      ),
                      _buildCompactDivider(),
                      _buildCompactStat(
                        (user.followersCount).toString(),
                        'Followers',
                      ),
                      _buildCompactDivider(),
                      _buildCompactStat(
                        (user.rating).toStringAsFixed(1),
                        'Rating',
                        ),
                    ],
                  ),
                  
                  // Bio section
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
                  
                  // Follow button only (no "View in Map" for regular users)
                  SizedBox(
                    width: 120,
                    child: _buildActionButton(
                      text: _isFollowing ? 'Following' : 'Follow',
                      onPressed: _isLoadingFollow ? null : _toggleFollow,
                      isLoading: _isLoadingFollow,
                      isPrimary: !_isFollowing,
                      isFollowing: _isFollowing,
                      accountType: user.accountType,
                    ),
                  ),
                  
                  // Alifi Favorite badge
                  if (isAlifiFavorite) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B35).withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                    children: [
                          Icon(Icons.verified, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'ALIFI FAVORITE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'InterDisplay',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Alifi Affiliated badge
                  if ((user.subscriptionPlan ?? '').toLowerCase() == 'alifi affiliated') ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'ALIFI AFFILIATED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'InterDisplay',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 30),
                  
                  // Custom Tab Bar
                  _buildCustomTabBar(false, false), // Regular user: not vet, not store
                  
                  const SizedBox(height: 20),
                  
                  // Tab Content
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _getCachedPetsWidget(),
                        _getCachedReviewsWidget(user),
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
    return StreamBuilder<User?>(
      stream: _userStream,
      builder: (context, snapshot) {
        final user = snapshot.data ?? widget.user;
        final isVet = user.accountType == 'vet';
        final isStore = user.accountType == 'store';
        final bool isAlifiFavorite = (user.subscriptionPlan ?? '').toLowerCase() == 'alifi favorite';

        // Regular users get a normal layout without banner
        if (!isVet && !isStore) {
          return _buildRegularUserProfile(user, isAlifiFavorite);
        }

        // Vets and stores get the banner layout
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Stack(
            children: [
              // Custom ScrollView with stretchy SliverAppBar
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    // Only trigger rebuild if profile picture animation needs updating
                    final double bannerHeight = MediaQuery.of(context).size.height * 0.25;
                    final double profilePictureTop = (_currentAppBarHeight == 0 ? bannerHeight : _currentAppBarHeight) - 50;
                    final double topPadding = MediaQuery.of(context).padding.top;
                    final double animationStartY = topPadding + 60;
                    
                    // Only rebuild if profile picture is in animation range
                    if (profilePictureTop <= animationStartY + 20) {
                      setState(() {
                        // Minimal rebuild for profile picture animation only
                      });
                    }
                  }
                  return false;
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                  // Stretchy SliverAppBar with banner and profile picture
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.height * 0.25,
                    floating: false,
                    pinned: false,
                    stretch: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: Container(),
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        final double currentHeight = constraints.maxHeight;
                        // Defer the state update to the next frame to avoid build re-entrancy
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          if (_currentAppBarHeight != currentHeight) {
                            setState(() {
                              _currentAppBarHeight = currentHeight;
                            });
                          }
                        });
                        
                        return FlexibleSpaceBar(
                          stretchModes: const [
                            StretchMode.zoomBackground,
                          ],
                          background: isAlifiFavorite && (user.coverPhotoURL ?? '').isNotEmpty
                              ? Image.network(
                                  user.coverPhotoURL!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.blue.withOpacity(0.8),
                                        Colors.blue.withOpacity(0.4),
                                      ],
                                    ),
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                  
                  // Profile content as SliverToBoxAdapter
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -60), // Pull content up to overlap
                      child: Container(
                        margin: const EdgeInsets.only(top: 60), // Space for profile picture
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 70, 20, 20), // Top padding for profile picture
                          child: Column(
                            children: [
                    // Display name
                    Text(
                      user.displayName ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                              const SizedBox(height: 12),
                    
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
                                      (user.followersCount).toString(),
                            'Followers',
                          ),
                          _buildCompactDivider(),
                          _buildCompactStat(
                                      (user.rating).toStringAsFixed(1),
                            'Rating',
                                ),
                              ] else if (isStore) ...[
                          _buildCompactStat(
                                      (user.totalOrders).toString(),
                            'Orders',
                          ),
                          _buildCompactDivider(),
                          _buildCompactStat(
                            (user.followersCount).toString(),
                            'Followers',
                          ),
                          _buildCompactDivider(),
                          _buildCompactStat(
                                      (user.rating).toStringAsFixed(1),
                                      'Rating',
                                ),
                              ] else ...[
                          _buildCompactStat(
                            _userPets.length.toString(),
                                      'Pets',
                          ),
                          _buildCompactDivider(),
                          _buildCompactStat(
                            (user.followersCount).toString(),
                                'Followers',
                          ),
                          _buildCompactDivider(),
                          _buildCompactStat(
                            (user.rating).toStringAsFixed(1),
                                      'Rating',
                          ),
                              ],
                        ],
                    ),
                    
                              // Bio section
                    if (user.basicInfo != null && user.basicInfo!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                      Text(
                        user.basicInfo!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    
                              const SizedBox(height: 16),
                    
                              // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          text: _isFollowing ? 'Following' : 'Follow',
                          onPressed: _isLoadingFollow ? null : _toggleFollow,
                          isLoading: _isLoadingFollow,
                          isPrimary: !_isFollowing,
                          isFollowing: _isFollowing,
                          accountType: user.accountType,
                        ),
                        // Only show Contact button for vets, no second button for stores
                        if (isVet) ...[
                          const SizedBox(width: 12),
                        _buildActionButton(
                            text: 'Contact',
                            onPressed: _contactVet,
                          isLoading: false,
                          isPrimary: false,
                          isFollowing: false,
                          accountType: user.accountType,
                        ),
                        ],
                      ],
                    ),
                              
                              // Alifi Favorite badge
                    if (isAlifiFavorite) ...[
                                const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B35).withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'ALIFI FAVORITE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'InterDisplay',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Alifi Affiliated badge
                    if ((user.subscriptionPlan ?? '').toLowerCase() == 'alifi affiliated') ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'ALIFI AFFILIATED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'InterDisplay',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                              
                              const SizedBox(height: 16),
                              
                                                          // Custom Tabs with fixed indicator
                            _buildCustomTabBar(isVet, isStore),
              
              // Tab content
                              SizedBox(
                                height: 400, // Fixed height for tab content
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    isVet
                        ? _getCachedPatientsWidget(user)
                        : isStore
                            ? _getCachedProductsWidget(user)
                            : _getCachedPetsWidget(),
                    _getCachedReviewsWidget(user),
                  ],
                ),
              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                      ],
                    ),
                  ),
              
              // Profile picture that follows the white container (TOP LAYER)
              _buildAnimatedProfilePicture(user),
              
              // Navigation buttons overlay
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      'assets/images/back_icon.png',
                      width: 24,
                      height: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 16,
                child: GestureDetector(
                  onTap: () => _showDropdownMenu(context, user),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedProfilePicture(User user) {
    // Calculate profile picture animation based on scroll position
    final double bannerHeight = MediaQuery.of(context).size.height * 0.25;
    final double profilePictureTop = (_currentAppBarHeight == 0 ? bannerHeight : _currentAppBarHeight) - 50;
    
    // Animation calculations
    final double topPadding = MediaQuery.of(context).padding.top;
    final double animationStartY = topPadding + 60; // When animation should start
    final double animationEndY = topPadding; // When profile picture should disappear
    
    // Calculate animation progress (0.0 = no animation, 1.0 = fully animated)
    double animationProgress = 0.0;
    if (profilePictureTop <= animationStartY) {
      final double animationRange = animationStartY - animationEndY;
      final double currentDistance = animationStartY - profilePictureTop;
      animationProgress = (currentDistance / animationRange).clamp(0.0, 1.0);
    }
    
    // Calculate scale and opacity based on animation progress
    final double scale = 1.0 - (animationProgress * 0.8); // Shrink to 20% of original size
    final double opacity = animationProgress >= 0.8 ? 0.0 : (1.0 - animationProgress * 1.5).clamp(0.0, 1.0); // Complete disappearance
    
    // Calculate radius based on scale
    final double baseRadius = 55.0;
    
    return Positioned(
      top: profilePictureTop,
      left: MediaQuery.of(context).size.width / 2 - baseRadius, // Keep center anchor point
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 100),
        child: Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // White border/outline
              CircleAvatar(
                radius: baseRadius,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: (user.photoURL ?? '').isNotEmpty
                      ? NetworkImage(user.photoURL!)
                      : null,
                  backgroundColor: (user.photoURL ?? '').isEmpty ? Colors.grey : null,
                  child: (user.photoURL ?? '').isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
              ),
              if (user.isVerified && scale > 0.5) // Hide verification badge when too small
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: ProfileVerificationBadge(
                    size: 24 * scale,
                    backgroundColor: Colors.white,
                    iconColor: const Color(0xFF1DA1F2),
                  ),
                ),
            ],
          ),
        ),
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