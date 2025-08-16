import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/navigation_service.dart';
import '../services/device_performance.dart';
import '../utils/app_fonts.dart';
import '../pages/adoption_center_page.dart';

import '../pages/marketplace_page.dart';
import '../pages/vets_page.dart';
import '../pages/groomer_service_page.dart';
import '../pages/trainer_service_page.dart';

class ServicesSection extends StatefulWidget {
  final bool showTitle;
  
  const ServicesSection({
    super.key,
    this.showTitle = true,
  });

  @override
  State<ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends State<ServicesSection> {
  late final DevicePerformance _devicePerformance;
  late final PerformanceTier _performanceTier;
  
  // Track which button is being pressed
  String? _pressedButtonId;

  @override
  void initState() {
    super.initState();
    _devicePerformance = DevicePerformance();
    _performanceTier = _devicePerformance.performanceTier;
  }

  @override
  Widget build(BuildContext context) {
    // Use RepaintBoundary only for medium and high performance devices
    final shouldUseRepaintBoundary = _performanceTier != PerformanceTier.low;
    
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) ...[
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.services,
              style: TextStyle(
                fontFamily: context.titleFont,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.1,
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            const SizedBox(height: 8), // Reduced spacing when no title
          ],
          // Services Grid
          Column(
            children: [
              // First row - 3 items
              Row(
                children: [
                  Expanded(
                    child: _buildServiceCard(
                      context,
                      'adoption_center',
                      'assets/images/adoptionservice.png',
                      AppLocalizations.of(context)!.adoptionCenter,
                      Colors.orange,
                      () => NavigationService.push(context, const AdoptionCenterPage()),
                      isAdoptionCenter: true, // Special flag for adoption center
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildServiceCard(
                      context,
                      'pet_store',
                      'assets/images/storeservice.png',
                      AppLocalizations.of(context)!.petStore,
                      Colors.green,
                      () => NavigationService.push(context, const MarketplacePage()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildServiceCard(
                      context,
                      'vets',
                      'assets/images/vetservice.png',
                      AppLocalizations.of(context)!.vet,
                      Colors.blue,
                      () => NavigationService.push(context, const VetsPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Second row - 2 items centered
              Row(
                children: [
                  const Spacer(flex: 1),
                  Expanded(
                    flex: 2,
                    child: _buildServiceCard(
                      context,
                      'trainers',
                      'assets/images/trainerservice.png',
                      AppLocalizations.of(context)!.trainers,
                      Colors.blue,
                      () => NavigationService.push(context, const TrainerServicePage()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildServiceCard(
                      context,
                      'groomers',
                      'assets/images/groomerservice.png',
                      AppLocalizations.of(context)!.groomers,
                      Colors.orange,
                      () => NavigationService.push(context, const GroomerServicePage()),
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );

    return shouldUseRepaintBoundary ? RepaintBoundary(child: content) : content;
  }

  Widget _buildServiceCard(
    BuildContext context,
    String buttonId,
    String imagePath,
    String title,
    Color borderColor,
    VoidCallback onTap, {
    bool isAdoptionCenter = false,
  }) {
    // Optimize image quality based on device performance
    final filterQuality = _performanceTier == PerformanceTier.low 
        ? FilterQuality.low 
        : FilterQuality.medium;
    
    // Reduce cache size for low-end devices
    final cacheSize = _performanceTier == PerformanceTier.low ? 60 : 120;
    
    // Use RepaintBoundary only for medium and high performance devices
    final shouldUseRepaintBoundary = _performanceTier != PerformanceTier.low;
    
    // Check if this button is being pressed
    final isPressed = _pressedButtonId == buttonId;
    
    Widget cardContent = GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressedButtonId = buttonId;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressedButtonId = null;
        });
        onTap();
      },
      onTapCancel: () {
        setState(() {
          _pressedButtonId = null;
        });
      },
      child: Transform.scale(
        scale: isPressed ? 0.95 : 1.0,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          height: 120, // Fixed height for consistent appearance
          decoration: BoxDecoration(
            color: Colors.white, // White background
            borderRadius: BorderRadius.circular(28), // Increased from 16 to 28
            border: Border.all(
              color: Colors.grey.shade300, // Gray outline
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isPressed ? 0.12 : 0.08),
                blurRadius: isPressed ? 8 : 12,
                offset: Offset(0, isPressed ? 2 : 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isPressed ? 0.06 : 0.04),
                blurRadius: isPressed ? 2 : 4,
                offset: Offset(0, isPressed ? 1 : 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Service Icon with conditional padding for adoption center
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.only(top: isAdoptionCenter ? 4.0 : 0.0), // Move adoption center icon down
                    child: Image.asset(
                      imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      cacheWidth: cacheSize, // Optimize memory usage by limiting cache size
                      cacheHeight: cacheSize,
                      filterQuality: filterQuality, // Balance quality and performance
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Service Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade800, // Dark gray text for better contrast on white
                    fontSize: 14,
                    fontWeight: FontWeight.w700, // Changed to bold
                    fontFamily: context.localizedFont, // Use localized font for service titles
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return shouldUseRepaintBoundary ? RepaintBoundary(child: cardContent) : cardContent;
  }
}
