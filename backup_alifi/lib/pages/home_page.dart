import 'package:flutter/material.dart' hide ScrollDirection;
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import '../models/fundraising.dart';
import '../models/lost_pet.dart';
import '../models/store_item.dart';
import '../icons.dart';
import '../widgets/placeholder_image.dart';
import '../widgets/scrollable_fade_container.dart';
import '../widgets/fundraising_card.dart';
import 'notification_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onNavigateToMap;

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
  bool _showHeader = false;
  bool _isAtTop = false;
  int _currentPetPage = 0;
  int _currentStorePage = 0;

  // Use mock data from models
  final List<LostPet> _lostPets = LostPet.mockPets;
  final List<StoreItem> _storeItems = StoreItem.mockItems;

  @override
  void initState() {
    super.initState();
    _petsScrollController.addListener(_onPetScroll);
    _storeScrollController.addListener(_onStoreScroll);
    _mainScrollController.addListener(_onMainScroll);
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
    final double itemWidth = MediaQuery.of(context).size.width * 0.85 + 16.0; // Width + horizontal margin
    final int page = (offset / itemWidth).round();
    
    if (page != _currentPetPage) {
      setState(() => _currentPetPage = page);
    }

    // If the scroll is ending (user lifts finger), snap to the nearest item
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
    if (page != _currentStorePage) {
      setState(() => _currentStorePage = page);
    }
  }

  void _onMainScroll() {
    if (!_mainScrollController.hasClients) return;
    
    // Show header when scrolling up, hide when scrolling down
    if (_mainScrollController.position.userScrollDirection == ScrollDirection.reverse && _mainScrollController.offset > 100) {
      if (_showHeader) {
        setState(() => _showHeader = false);
      }
    } else if (_mainScrollController.position.userScrollDirection == ScrollDirection.forward && _mainScrollController.offset > 100) {
      if (!_showHeader) {
        setState(() => _showHeader = true);
      }
    }

    // Check if we're at the top of the scroll
    final bool isAtTop = _mainScrollController.offset < 5;
    if (isAtTop != _isAtTop) {
      setState(() => _isAtTop = isAtTop);
    }
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
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
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FundraisingCard(
                          fundraising: Fundraising.mockData,
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
          AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            offset: Offset(0, _showHeader ? 0 : -1),
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
                              SvgPicture.string(
                                AppIcons.trophyIcon,
                                width: 28,
                                height: 28,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildHeaderButton(
                                    icon: AppIcons.bellIcon,
                                    onTap: () {},
                                  ),
                                  const SizedBox(width: 8),
                                  const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.person, color: Colors.white),
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
                  SvgPicture.string(
                    AppIcons.trophyIcon,
                    width: 28,
                    height: 28,
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good afternoon, user!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        Text(
          "What's new?",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildWhatsNewSlider() {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final containerWidth = constraints.maxWidth;
              final itemWidth = MediaQuery.of(context).size.width * 0.85;
              final totalWidth =
                  itemWidth * _lostPets.length + 16.0 * (_lostPets.length - 1);

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
                  itemCount: _lostPets.length,
                  itemBuilder: (context, index) {
                    final pet = _lostPets[index];
                    final width = MediaQuery.of(context).size.width * 0.85;
                    return AnimatedScale(
                      scale: _currentPetPage == index ? 1.0 : 0.92,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        width: width,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 24.0),
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
                              const PlaceholderImage(
                                width: 100,
                                height: 100,
                                isCircular: true,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      pet.name,
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
                                          '${pet.lastLocation['latitude']?.toStringAsFixed(4)}, ${pet.lastLocation['longitude']?.toStringAsFixed(4)}',
                                          style: TextStyle(
                                              color: Colors.orange[700]),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Text(
                                          'Status: ',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Text(
                                          pet.status,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: widget.onNavigateToMap,
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
                    );
                  },
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _lostPets.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == _currentPetPage
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
                      color: index == _currentStorePage
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
