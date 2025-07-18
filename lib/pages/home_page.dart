import 'package:flutter/material.dart' hide ScrollDirection;
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:timeago/timeago.dart' as timeago;
import '../models/fundraising.dart';
import '../models/lost_pet.dart';
import '../models/store_item.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../icons.dart';
import '../widgets/placeholder_image.dart';
import '../widgets/scrollable_fade_container.dart';
import '../widgets/fundraising_card.dart';
import '../widgets/lost_pet_card.dart';
import 'notification_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'leaderboard_page.dart';
import '../main.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'user_profile_page.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show Distance, LengthUnit, LatLng;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final void Function(LostPet pet) onNavigateToMap;

  const HomePage({
    super.key,
    required this.onNavigateToMap,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _petsScrollController = ScrollController();
  final ScrollController _storeScrollController = ScrollController();
  final ScrollController _mainScrollController = ScrollController();
  final DatabaseService _databaseService = DatabaseService();
  final ValueNotifier<bool> _showHeader = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isAtTop = ValueNotifier<bool>(false);
  final ValueNotifier<int> _currentPetPage = ValueNotifier<int>(0);
  final ValueNotifier<int> _currentStorePage = ValueNotifier<int>(0);
  Position? _currentPosition;
  bool _locationEnabled = false;
  List<LostPet> _lostPets = [];
  List<LostPet> _filteredLostPets = [];
  final Distance _distance = const Distance();

  // Use mock data for store items
  final List<StoreItem> _storeItems = StoreItem.mockItems;

  @override
  void initState() {
    super.initState();
    _petsScrollController.addListener(_onPetScroll);
    _storeScrollController.addListener(_onStoreScroll);
    _mainScrollController.addListener(_onMainScroll);
    _initializeLocationAndLoadPets();
  }

  Future<void> _initializeLocationAndLoadPets() async {
    try {
      final status = await Geolocator.requestPermission();
      if (status == LocationPermission.denied || status == LocationPermission.deniedForever) {
        _locationEnabled = false;
      } else {
        _locationEnabled = true;
        _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      }
    } catch (e) {
      _locationEnabled = false;
    }
    _loadRecentLostPets();
  }

  Future<void> _loadRecentLostPets() async {
    _databaseService.getRecentLostPets().listen((pets) {
      if (mounted) {
        setState(() {
          _lostPets = pets;
          _filterLostPetsByLocation();
        });
      }
    });
  }

  void _filterLostPetsByLocation() {
    if (_locationEnabled && _currentPosition != null) {
      final userLatLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      _filteredLostPets = _lostPets.where((pet) {
        final double dist = _distance.as(LengthUnit.Meter, userLatLng, latlong.LatLng(pet.location.latitude, pet.location.longitude));
        return dist <= 500.0;
      }).toList();
    } else {
      _filteredLostPets = List.from(_lostPets);
    }
  }

  @override
  void dispose() {
    _petsScrollController.removeListener(_onPetScroll);
    _storeScrollController.removeListener(_onStoreScroll);
    _mainScrollController.removeListener(_onMainScroll);
    _petsScrollController.dispose();
    _storeScrollController.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  void _onPetScroll() {
    if (!_petsScrollController.hasClients) return;
    final double offset = _petsScrollController.offset;
    final double itemWidth = MediaQuery.of(context).size.width * 0.85 + 16.0;
    final int page = (offset / itemWidth).round();
    if (page != _currentPetPage.value) {
      _currentPetPage.value = page;
    }
    if (!_petsScrollController.position.isScrollingNotifier.value) {
      final double targetOffset = page * itemWidth;
      _petsScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onStoreScroll() {
    if (!_storeScrollController.hasClients) return;
    final double offset = _storeScrollController.offset;
    final double itemWidth = MediaQuery.of(context).size.width * 0.6;
    final int page = (offset / itemWidth).round();
    if (page != _currentStorePage.value) {
      _currentStorePage.value = page;
    }
  }

  void _onMainScroll() {
    if (!_mainScrollController.hasClients) return;
    if (_mainScrollController.position.userScrollDirection == ScrollDirection.reverse && _mainScrollController.offset > 100) {
      if (_showHeader.value) {
        _showHeader.value = false;
      }
    } else if (_mainScrollController.position.userScrollDirection == ScrollDirection.forward && _mainScrollController.offset > 100) {
      if (!_showHeader.value) {
        _showHeader.value = true;
      }
    }
    final bool isAtTop = _mainScrollController.offset < 5;
    if (isAtTop != _isAtTop.value) {
      _isAtTop.value = isAtTop;
    }
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  void _showLostPetDetails(LostPet pet) async {
    final user = await showGeneralDialog<User?>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Lost Pet Details',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic));
        return SlideTransition(
          position: offset,
          child: Opacity(
            opacity: anim1.value,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: _LostPetDialogContent(pet: pet),
                      ),
                    ),
                    // X close button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.close, size: 22, color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (user != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UserProfilePage(user: user),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              controller: _mainScrollController,
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildGreeting(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildWhatsNewSlider(),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        _buildStoreSection(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.volunteer_activism,
                                color: Color(0xFF4CAF50),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Fundraising',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FundraisingCard(
                          fundraising: Fundraising(
                            id: 'fund_001',
                            title: 'Animal Shelter Expansion',
                            description: 'Help us expand our shelter to accommodate more animals in need.',
                            currentAmount: 324223.21,
                            goalAmount: 635000.00,
                            creatorId: 'user_001',
                            createdAt: DateTime.now(),
                            endDate: DateTime.now().add(const Duration(days: 30)),
                            status: 'active',
                            supporterIds: ['user_001', 'user_002', 'user_003'],
                          ),
                        ),
                        // Add bottom spacing to prevent nav bar overlap
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Collapsible header
          ValueListenableBuilder<bool>(
            valueListenable: _showHeader,
            builder: (context, showHeader, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: _isAtTop,
                builder: (context, isAtTop, __) {
                  return AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
                    offset: Offset(0, (showHeader && !isAtTop) ? 0 : -1),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  height: 56 + MediaQuery.of(context).padding.top,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: MediaQuery.of(context).padding.top,
                    ),
                    child: SizedBox(
                      height: 56,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Center text
                          const Center(
                            child: Text(
                              'alifi',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                          // Left and right elements
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.menu),
                                    onPressed: () => _navigateToSettings(context),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const LeaderboardPage(),
                                        ),
                                      );
                                    },
                                    child: Image.asset(
                                      'assets/images/leaderboard_3d.png',
                                    width: 28,
                                    height: 28,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildHeaderButton(
                                    icon: AppIcons.bellIcon,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const NotificationPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const ProfilePage(),
                                        ),
                                      );
                                    },
                                    child: const CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.grey,
                                      child: Icon(Icons.person, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 56, // Fixed height for consistency
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center text
          const Center(
            child: Text(
              'alifi',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
          // Left and right elements
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => _navigateToSettings(context),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LeaderboardPage(),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/images/leaderboard_3d.png',
                    width: 28,
                    height: 28,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildHeaderButton(
                    icon: AppIcons.bellIcon,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const GeminiChatBox(),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: SvgPicture.string(
              icon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final user = authService.currentUser;
        final name = user?.displayName?.isNotEmpty == true
            ? user!.displayName
            : (user?.username?.isNotEmpty == true ? user!.username : 'user');
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              'Good afternoon, $name!',
              style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
            const Text(
          "What's new?",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
          ),
        ),
      ],
        );
      },
    );
  }

  Widget _buildWhatsNewSlider() {
    final petsToShow = _filteredLostPets;
    if (petsToShow.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No lost pets reported nearby',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final containerWidth = constraints.maxWidth;
              final itemWidth = MediaQuery.of(context).size.width * 0.85;
              final totalWidth = itemWidth * petsToShow.length + 16.0 * (petsToShow.length - 1);

              return ScrollableFadeContainer(
                scrollController: _petsScrollController,
                containerWidth: containerWidth,
                contentWidth: totalWidth,
                child: ListView.builder(
                  controller: _petsScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const PageScrollPhysics().applyTo(
                    const BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: (MediaQuery.of(context).size.width - itemWidth) / 2,
                  ),
                  itemCount: petsToShow.length,
                  itemBuilder: (context, index) {
                    final lostPet = petsToShow[index];
                    final width = MediaQuery.of(context).size.width * 0.85;
                    return GestureDetector(
                      onTap: () => _showLostPetDetails(lostPet),
                      child: AnimatedScale(
                      scale: _currentPetPage.value == index ? 1.0 : 0.92,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        width: width,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(90),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: lostPet.pet.imageUrls.isNotEmpty
                                    ? CachedNetworkImage(
    imageUrl: lostPet.pet.imageUrls.first,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
    placeholder: (context, url) => const PlaceholderImage(
      width: 100,
      height: 100,
      isCircular: true,
    ),
    errorWidget: (context, url, error) => const PlaceholderImage(
                                          width: 100,
                                          height: 100,
                                          isCircular: true,
                                        ),
    fadeInDuration: const Duration(milliseconds: 300),
                                      )
                                    : const PlaceholderImage(
                                        width: 100,
                                        height: 100,
                                        isCircular: true,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      lostPet.pet.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Text(
                                          'Last seen: ',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Text(
                                          timeago.format(lostPet.lastSeenDate),
                                          style: TextStyle(
                                            color: Colors.orange[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Text(
                                          'Location: ',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Expanded(
                                          child: Text(
                                            lostPet.address,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                        onPressed: () => widget.onNavigateToMap(lostPet),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF59E0B),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        minimumSize: const Size(120, 36),
                                        elevation: 4,
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.map, size: 18),
                                          SizedBox(width: 4),
                                          Text('Open maps'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            petsToShow.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPetPage.value == index
                    ? const Color(0xFFF59E0B)
                    : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 8),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                SvgPicture.string(
                  AppIcons.storeIcon,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'You may be Interested',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward, color: Colors.grey[600]),
              ],
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 220,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final containerWidth = constraints.maxWidth;
                    final itemWidth = MediaQuery.of(context).size.width * 0.6;
                    final totalWidth = itemWidth * _storeItems.length +
                        16.0 * (_storeItems.length - 1);

                    return ScrollableFadeContainer(
                      scrollController: _storeScrollController,
                      containerWidth: containerWidth,
                      contentWidth: totalWidth,
                      child: ListView.builder(
                        controller: _storeScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _storeItems.length,
                        itemBuilder: (context, index) {
                          final item = _storeItems[index];
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final width =
                                  MediaQuery.of(context).size.width * 0.6;
                              return Container(
                                width: width,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      offset: const Offset(0, 8),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    children: [
                                      const Positioned.fill(
                                        child: PlaceholderImage(
                                          width: double.infinity,
                                          height: double.infinity,
                                          borderRadius: 0,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(16),
                                            ),
                                          ),
                                          child: Text(
                                            '${item.price.toStringAsFixed(0)}DZD',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _storeItems.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentStorePage.value == index
                          ? const Color(0xFFF59E0B)
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpinningLoader extends StatefulWidget {
  @override
  State<_SpinningLoader> createState() => _SpinningLoaderState();
}

class _SpinningLoaderState extends State<_SpinningLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 6.28319, // 2*pi
          child: child,
        );
      },
      child: Image.asset(
        'assets/images/loading.png',
        width: 40,
        height: 40,
      ),
    );
  }
}

class _LostPetDialogContent extends StatelessWidget {
  final LostPet pet;
  const _LostPetDialogContent({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (pet.pet.imageUrls.isNotEmpty)
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(pet.pet.imageUrls.first),
            backgroundColor: Colors.grey[200],
          )
        else
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            child: Icon(Icons.pets, size: 48, color: Colors.grey[400]),
          ),
        const SizedBox(height: 16),
        Text(
          pet.pet.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          pet.pet.breed,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          'Last seen: ${pet.address}',
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          'Reported: ${pet.lastSeenDate}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        if (pet.reward != null && pet.reward!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.card_giftcard, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Reward: ${pet.reward}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (pet.additionalInfo != null && pet.additionalInfo!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            pet.additionalInfo!,
            style: const TextStyle(fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        FutureBuilder<User?>(
          future: DatabaseService().getUser(pet.reportedByUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 40,
                width: 40,
                child: _SpinningLoader(),
              );
            }
            final user = snapshot.data;
            if (user == null) {
              return const SizedBox();
            }
            return ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(user);
              },
              icon: const Icon(Icons.person),
              label: const Text("Visit Owner's Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
