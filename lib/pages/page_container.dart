import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import '../icons.dart';
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

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(
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
      ),
      MapPage(
        onSearchFocusChange: (isVisible) {
          if (_isVisible != isVisible) {
            _toggleVisibility();
          }
        },
      ),
      const MyPetsPage(),
      const MarketplacePage(),
      const UserSearchPage(), // Add search as a regular page
    ];

    _hideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1),
    ).animate(CurvedAnimation(
      parent: _hideController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _hideController,
      curve: Curves.easeInOut,
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
    return GestureDetector(
      onTap: _toggleVisibility,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
            // Fade effect
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 120,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(1),
                        ],
                        stops: const [0.2, 0.9],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0),
                              Colors.black.withOpacity(0.25),
                            ],
                            stops: const [0.2, 0.9],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Navigation bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: GestureDetector(
                    onTap: () {
                      if (!_isVisible && !_isAIAssistantExpanded) {
                        _toggleVisibility();
                      }
                    },
                    child: _isAIAssistantExpanded ? const SizedBox.shrink() : _buildBottomNavBar(),
                  ),
                ),
              ),
            ),
          ],
        ),
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
    final Color activeIconColor = const Color(0xFFFF9E42);

    final int searchPageIndex = 4;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(left: sidePadding, right: sidePadding, bottom: 24.0),
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
    );
  }
}
