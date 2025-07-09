import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import '../icons.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'my_pets_page.dart';
import 'profile_page.dart';

class PageContainer extends StatefulWidget {
  const PageContainer({super.key});

  @override
  State<PageContainer> createState() => _PageContainerState();
}

class _PageContainerState extends State<PageContainer> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isVisible = true;
  late AnimationController _hideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      MapPage(
        onSearchFocusChange: (isVisible) {
          if (_isVisible != isVisible) {
            _toggleVisibility();
          }
        },
      ),
      const MyPetsPage(),
      const ProfilePage(),
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
                      if (!_isVisible) {
                        _toggleVisibility();
                      }
                    },
                    child: _buildBottomNavBar(),
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
    final maxNavWidth = 320.0; // Current max width
    final navWidth = screenWidth < maxNavWidth + 32 ? screenWidth - 32 : maxNavWidth;
    final itemWidth = navWidth / 4;
    final indicatorWidth = itemWidth;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  width: navWidth,
                  height: 64,
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
                          left: _currentIndex * itemWidth,
                          top: 4,
                          child: Container(
                            width: indicatorWidth,
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.15),
                                  width: 1,
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
                                height: 64,
                                child: Center(
                                  child: index == 1 
                                    ? Icon(
                                        Icons.map,
                                        size: 24,
                                        color: _currentIndex == index
                                          ? const Color(0xFFFF9E42)
                                          : Colors.black,
                                      )
                                    : index == 2
                                      ? Icon(
                                          Icons.pets,
                                          size: 24,
                                          color: _currentIndex == index
                                            ? const Color(0xFFFF9E42)
                                            : Colors.black,
                                        )
                                      : SvgPicture.string(
                                        icons[index]!,
                                        width: 24,
                                        height: 24,
                                        colorFilter: ColorFilter.mode(
                                          _currentIndex == index
                                              ? const Color(0xFFFF9E42)
                                              : Colors.black,
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
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.45),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: SvgPicture.string(
                      AppIcons.searchIcon,
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
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
