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
import 'package:provider/provider.dart';
import '../services/map_focus_service.dart';
import '../services/auth_service.dart';
import '../services/user_preferences_service.dart';
import 'location_setup_page.dart';

class PageContainer extends StatefulWidget {
  const PageContainer({super.key});

  @override
  State<PageContainer> createState() => _PageContainerState();
}

// Global key to access PageContainer from anywhere
final GlobalKey<_PageContainerState> pageContainerKey = GlobalKey<_PageContainerState>();

class _PageContainerState extends State<PageContainer> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late List<Widget> _pages;
  // Track side menu progress (0.0 closed → 1.0 open) to move nav bar with HomePage
  double _sideMenuProgress = 0.0;
  // Flag to prevent showing location setup multiple times
  bool _hasShownLocationSetup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _pages = [
      _PersistentHomePage(
        onNavigateToMap: () {
          setState(() {
            _currentIndex = 1;
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



    // Check if user needs location setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationSetup();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Check location setup when app resumes
    if (state == AppLifecycleState.resumed) {
      // Reset the flag so we can check again
      _hasShownLocationSetup = false;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkLocationSetup();
      });
    }
  }

  void navigateToMapWithFocus() {
    setState(() {
      _currentIndex = 1; // Map tab index
    });
  }

  // Check if the current user needs to set up their business location
  Future<void> _checkLocationSetup() async {
    try {
      // Prevent showing location setup multiple times in the same session
      if (_hasShownLocationSetup) return;
      
      final authService = context.read<AuthService>();
      
      if (authService.needsLocationSetup()) {
        _hasShownLocationSetup = true;
        
        // Show location setup page as a modal
        if (mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LocationSetupPage(),
              fullscreenDialog: true,
            ),
          );
          
          // Refresh user data after returning from location setup
          if (mounted) {
            await authService.refreshUserData();
          }
        }
      }
    } catch (e) {
      print('Error checking location setup: $e');
    }
  }

  // Public method to check location setup (can be called from outside)
  Future<void> checkLocationSetup() async {
    _hasShownLocationSetup = false; // Reset flag to allow checking again
    await _checkLocationSetup();
  }

  

  // Helper to determine if nav bar background is dark based on theme brightness
  bool _isNavBarBackgroundDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Check location setup when user data changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authService.currentUser != null) {
            _checkLocationSetup();
          }
        });
        
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
                  child: _buildBottomNavBar(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Consumer<UserPreferencesService>(
      builder: (context, userPreferences, child) {
        return _buildBottomNavBarContent(userPreferences.tabBarBlurEnabled);
      },
    );
  }

  Widget _buildBottomNavBarContent(bool blurEnabled) {
    final screenWidth = MediaQuery.of(context).size.width;
    const maxNavWidth = 320.0;
    const minNavWidth = 220.0;
    // const minBarHeight = 44.0; // unused
    // const minIconSize = 16.0; // unused
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
            _buildNavContainer(
              blurEnabled: blurEnabled,
              width: navWidth,
              height: barHeight,
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
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _currentIndex = searchPageIndex),
              child: _buildNavContainer(
                blurEnabled: blurEnabled,
                width: searchButtonSize,
                height: searchButtonSize,
                isCircular: true,
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
          ],
        ),
        ),
        ],
      ),
    );
  }

  Widget _buildNavContainer({
    required bool blurEnabled,
    required double width,
    required double height,
    bool isCircular = false,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: blurEnabled
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.45),
                  borderRadius: isCircular ? null : BorderRadius.circular(32),
                  shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: child,
              ),
            )
          : Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: isCircular ? null : BorderRadius.circular(32),
                shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: child,
            ),
    );
  }
}

// Persistent wrapper classes to keep tabs alive
class _PersistentHomePage extends StatefulWidget {
  final VoidCallback onNavigateToMap;
  final ValueChanged<double>? onSideMenuProgressChanged;

  const _PersistentHomePage({
    required this.onNavigateToMap,
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
    return Consumer<MapFocusService>(
      builder: (context, mapFocusService, child) {
        return MapPage(focusUser: mapFocusService.focusUser);
      },
    );
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
