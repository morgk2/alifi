import 'package:flutter/material.dart';

class ProfileSkeletonLoader extends StatefulWidget {
  final bool isVet;
  final bool isStore;
  final bool showTabs;

  const ProfileSkeletonLoader({
    super.key,
    this.isVet = false,
    this.isStore = false,
    this.showTabs = true,
  });

  @override
  State<ProfileSkeletonLoader> createState() => _ProfileSkeletonLoaderState();
}

class _ProfileSkeletonLoaderState extends State<ProfileSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Add top padding for status bar
            SizedBox(height: MediaQuery.of(context).padding.top + 10),
            
            // Main profile container
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile picture
                    _buildSkeletonCircle(100),
                    const SizedBox(height: 16),
                    
                    // Name and verification
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSkeletonBox(150, 24, borderRadius: 4),
                        const SizedBox(width: 8),
                        _buildSkeletonBox(20, 20, borderRadius: 10),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Username/subtitle
                    _buildSkeletonBox(100, 16, borderRadius: 4),
                    const SizedBox(height: 16),
                    
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatSkeleton(),
                        _buildVerticalDivider(),
                        _buildStatSkeleton(),
                        _buildVerticalDivider(),
                        widget.isVet || widget.isStore 
                          ? _buildStatSkeleton()
                          : _buildPetsRescuedSkeleton(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Bio section
                    Column(
                      children: [
                        _buildSkeletonBox(double.infinity, 16, borderRadius: 4),
                        const SizedBox(height: 6),
                        _buildSkeletonBox(250, 16, borderRadius: 4),
                        const SizedBox(height: 6),
                        _buildSkeletonBox(180, 16, borderRadius: 4),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Action buttons
                    _buildActionButtonsSkeleton(),
                    const SizedBox(height: 20),
                    
                    // Alifi affiliated badge (sometimes)
                    _buildSkeletonBox(160, 32, borderRadius: 20),
                    const SizedBox(height: 20),
                    
                    // Tabs
                    if (widget.showTabs) _buildTabsSkeleton(),
                  ],
                ),
              ),
            ),
            
            // Tab content area
            if (widget.showTabs) _buildTabContentSkeleton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSkeleton() {
    return Column(
      children: [
        _buildSkeletonBox(30, 20, borderRadius: 4),
        const SizedBox(height: 4),
        _buildSkeletonBox(50, 14, borderRadius: 4),
      ],
    );
  }

  Widget _buildPetsRescuedSkeleton() {
    return Column(
      children: [
        _buildSkeletonBox(30, 20, borderRadius: 4),
        const SizedBox(height: 4),
        _buildSkeletonBox(35, 14, borderRadius: 4),
        const SizedBox(height: 2),
        _buildSkeletonBox(55, 14, borderRadius: 4),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 20,
      color: Colors.grey[300]?.withOpacity(0.3),
    );
  }

  Widget _buildActionButtonsSkeleton() {
    return Row(
      children: [
        Expanded(
          child: _buildSkeletonBox(double.infinity, 44, borderRadius: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSkeletonBox(double.infinity, 44, borderRadius: 22),
        ),
        if (widget.isVet || widget.isStore) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _buildSkeletonBox(double.infinity, 44, borderRadius: 22),
          ),
        ],
      ],
    );
  }

  Widget _buildTabsSkeleton() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildSkeletonBox(80, 16, borderRadius: 4),
              const SizedBox(height: 8),
              Container(
                height: 3,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300]?.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _buildSkeletonBox(60, 16, borderRadius: 4),
              const SizedBox(height: 11),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabContentSkeleton() {
    return Container(
      color: Colors.white,
      height: 400,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: widget.isVet 
          ? _buildPatientsGridSkeleton()
          : widget.isStore 
            ? _buildProductsGridSkeleton()
            : _buildPetsGridSkeleton(),
      ),
    );
  }

  Widget _buildPetsGridSkeleton() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Expanded(
              child: _buildSkeletonBox(double.infinity, double.infinity, borderRadius: 12),
            ),
            const SizedBox(height: 8),
            _buildSkeletonBox(60, 14, borderRadius: 4),
          ],
        );
      },
    );
  }

  Widget _buildProductsGridSkeleton() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSkeletonBox(double.infinity, double.infinity, borderRadius: 12),
            ),
            const SizedBox(height: 8),
            _buildSkeletonBox(double.infinity, 16, borderRadius: 4),
            const SizedBox(height: 4),
            _buildSkeletonBox(80, 14, borderRadius: 4),
          ],
        );
      },
    );
  }

  Widget _buildPatientsGridSkeleton() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              _buildSkeletonCircle(50),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeletonBox(120, 16, borderRadius: 4),
                    const SizedBox(height: 4),
                    _buildSkeletonBox(80, 14, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonBox(double width, double height, {double borderRadius = 8}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300]?.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCircle(double size) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey[300]?.withOpacity(_animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
