import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import '../icons.dart';
import '../utils/navigation_bar_detector.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'my_pets_page.dart';
import 'marketplace_page.dart';
import 'user_search_page.dart';

class PageContainer extends StatefulWidget {
  const PageContainer({super.key});

  @override
  State<PageContainer> createState() => _PageContainerState();
}

class _PageContainerState extends State<PageContainer> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isVisible = true;
  bool _isAIAssistantExpanded = false;
  late AnimationController _hideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late List<Widget> _pages;
  // Track side menu progress (0.0 closed → 1.0 open) to move nav bar with HomePage
  double _sideMenuProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _pages = [
      _PersistentHomePage(
        onNavigateToMap: () {
          setState(() {
            _currentIndex = 1;
          });
        },
        onAIAssistantExpanded: (expanded) {
          setState(() {
            _isAIAssistantExpanded = expanded;
            if (expanded) {
              _hideController.forward();
            } else {
              _hideController.reverse();
            }
          });
        },
        onSideMenuProgressChanged: (progress) {
          if (_currentIndex == 0) {
            setState(() {
              _sideMenuProgress = progress;
            });
          }
        },
      ),
      const _PersistentMapPage(),
      const _PersistentMyPetsPage(),
      const _PersistentMarketplacePage(),
      const _PersistentUserSearchPage(),
    ];

    _hideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 2), // Move further down for smoother animation
    ).animate(CurvedAnimation(
      parent: _hideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _hideController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _hideController.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
      if (_isVisible) {
        _hideController.reverse();
      } else {
        _hideController.forward();
      }
    });
  }

  // Helper to determine if nav bar background is dark based on theme brightness
  bool _isNavBarBackgroundDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Transform.translate(
              offset: Offset(MediaQuery.of(context).size.width * 0.65 * (_currentIndex == 0 ? _sideMenuProgress : 0.0), 0),
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildBottomNavBar(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    const maxNavWidth = 320.0;
    const minNavWidth = 220.0;
    const minBarHeight = 44.0;
    const minIconSize = 16.0;
    double sidePadding = 16.0;
    double barHeight = 64;
    double iconSize = 24;
    double indicatorHeight = 52;
    double indicatorRadius = 26;
    double searchButtonSize = barHeight;
    double spacing = sidePadding < 12 ? 6 : 12;

    // Responsive adjustments for very slim screens
    if (screenWidth < minNavWidth + 2 * sidePadding + searchButtonSize + spacing) {
      sidePadding = 6.0;
      barHeight = 44;
      iconSize = 16;
      indicatorHeight = 36;
      indicatorRadius = 14;
      searchButtonSize = barHeight;
      spacing = 4;
    }

    double navWidth = screenWidth - 2 * sidePadding - searchButtonSize - spacing;
    if (navWidth > maxNavWidth) navWidth = maxNavWidth;
    if (navWidth < minNavWidth) navWidth = minNavWidth;
    final itemWidth = navWidth / 4;
    final indicatorWidth = itemWidth;

    final bool isDarkBg = _isNavBarBackgroundDark(context);
    final Color defaultIconColor = isDarkBg ? Colors.white : Colors.black;
    const Color activeIconColor = Color(0xFFFF9E42);

    const int searchPageIndex = 4;

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          // Black gradient fade
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
          // Navigation bar
          Padding(
        padding: EdgeInsets.only(
          left: sidePadding, 
          right: sidePadding, 
          bottom: NavigationBarDetector.getRecommendedBottomPadding(context),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  width: navWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Stack(
                      children: [
                        // Active indicator
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          left: (_currentIndex < searchPageIndex ? _currentIndex : 0) * itemWidth,
                          top: 4,
                          child: AnimatedSlide(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            offset: _currentIndex == searchPageIndex ? const Offset(2.5, 0) : Offset.zero,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: _currentIndex == searchPageIndex ? 0.0 : 1.0,
                              curve: Curves.easeInOut,
                              child: Container(
                                width: indicatorWidth,
                                height: indicatorHeight,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300]!.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(indicatorRadius),
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.15),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Navigation items
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) {
                            final icons = [
                              AppIcons.homeIcon,
                              null, // Map icon handled separately
                              null, // Pets icon handled separately
                              AppIcons.storeIcon,
                            ];
                            return GestureDetector(
                              onTap: () => setState(() => _currentIndex = index),
                              behavior: HitTestBehavior.opaque,
                              child: SizedBox(
                                width: itemWidth,
                                height: barHeight,
                                child: Center(
                                  child: index == 1 
                                    ? Icon(
                                        Icons.map,
                                        size: iconSize,
                                        color: _currentIndex == index
                                          ? activeIconColor
                                          : defaultIconColor,
                                      )
                                    : index == 2
                                      ? Icon(
                                          Icons.pets,
                                          size: iconSize,
                                          color: _currentIndex == index
                                            ? activeIconColor
                                            : defaultIconColor,
                                        )
                                      : SvgPicture.string(
                                        icons[index]!,
                                        width: iconSize,
                                        height: iconSize,
                                        colorFilter: ColorFilter.mode(
                                          _currentIndex == index
                                              ? activeIconColor
                                              : defaultIconColor,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _currentIndex = searchPageIndex),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: searchButtonSize,
                    height: searchButtonSize,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.45),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: SvgPicture.string(
                        AppIcons.searchIcon,
                        width: iconSize,
                        height: iconSize,
                        colorFilter: ColorFilter.mode(
                          _currentIndex == searchPageIndex
                              ? activeIconColor
                              : defaultIconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
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

// Persistent wrapper classes to keep tabs alive
class _PersistentHomePage extends StatefulWidget {
  final VoidCallback onNavigateToMap;
  final Function(bool) onAIAssistantExpanded;
  final ValueChanged<double>? onSideMenuProgressChanged;

  const _PersistentHomePage({
    required this.onNavigateToMap,
    required this.onAIAssistantExpanded,
    this.onSideMenuProgressChanged,
  });

  @override
  State<_PersistentHomePage> createState() => _PersistentHomePageState();
}

class _PersistentHomePageState extends State<_PersistentHomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return HomePage(
      onNavigateToMap: widget.onNavigateToMap,
      onAIAssistantExpanded: widget.onAIAssistantExpanded,
      onSideMenuProgressChanged: widget.onSideMenuProgressChanged,
    );
  }
}

class _PersistentMapPage extends StatefulWidget {
  const _PersistentMapPage();

  @override
  State<_PersistentMapPage> createState() => _PersistentMapPageState();
}

class _PersistentMapPageState extends State<_PersistentMapPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const MapPage();
  }
}

class _PersistentMyPetsPage extends StatefulWidget {
  const _PersistentMyPetsPage();

  @override
  State<_PersistentMyPetsPage> createState() => _PersistentMyPetsPageState();
}

class _PersistentMyPetsPageState extends State<_PersistentMyPetsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const MyPetsPage();
  }
}

class _PersistentMarketplacePage extends StatefulWidget {
  const _PersistentMarketplacePage();

  @override
  State<_PersistentMarketplacePage> createState() => _PersistentMarketplacePageState();
}

class _PersistentMarketplacePageState extends State<_PersistentMarketplacePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const MarketplacePage();
  }
}

class _PersistentUserSearchPage extends StatefulWidget {
  const _PersistentUserSearchPage();

  @override
  State<_PersistentUserSearchPage> createState() => _PersistentUserSearchPageState();
}

class _PersistentUserSearchPageState extends State<_PersistentUserSearchPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const UserSearchPage();
  }
}
