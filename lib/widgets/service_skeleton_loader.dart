import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ServiceSkeletonLoader extends StatefulWidget {
  final Color serviceColor;
  final int itemCount;

  const ServiceSkeletonLoader({
    super.key,
    this.serviceColor = Colors.blue,
    this.itemCount = 3,
  });

  @override
  State<ServiceSkeletonLoader> createState() => _ServiceSkeletonLoaderState();
}

class _ServiceSkeletonLoaderState extends State<ServiceSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            // Header Section Skeleton
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  
                  // Service Icon Banner Skeleton
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: _buildShimmerBox(120, 120, isCircular: true),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Section Title Skeleton
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildShimmerBox(20, 20, isCircular: true),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildShimmerBox(200, 18),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildShimmerBox(50, 14),
                                ],
                              ),
                              const SizedBox(height: 4),
                              _buildShimmerBox(150, 13),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildShimmerBox(60, 14),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
            // Service Cards Skeleton
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildServiceCardSkeleton(),
                childCount: widget.itemCount,
              ),
            ),
            
            // Bottom Padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceCardSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Image Skeleton
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                // Main image area
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: _buildShimmerBox(double.infinity, double.infinity),
                ),
                
                // Service type badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildShimmerBox(60, 24),
                ),
              ],
            ),
          ),
          
          // Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with profile and rating
                Row(
                  children: [
                    // Profile image
                    _buildShimmerBox(40, 40, isCircular: true),
                    const SizedBox(width: 12),
                    
                    // Name and date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerBox(100, 16),
                          const SizedBox(height: 4),
                          _buildShimmerBox(80, 12),
                        ],
                      ),
                    ),
                    
                    // Rating
                    _buildShimmerBox(60, 16),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Service title
                _buildShimmerBox(180, 20),
                
                const SizedBox(height: 12),
                
                // Location
                Row(
                  children: [
                    _buildShimmerBox(16, 16, isCircular: true),
                    const SizedBox(width: 8),
                    _buildShimmerBox(140, 14),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Pet types chips
                Row(
                  children: [
                    _buildShimmerBox(60, 24),
                    const SizedBox(width: 8),
                    _buildShimmerBox(50, 24),
                    const SizedBox(width: 8),
                    _buildShimmerBox(40, 24),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Footer with availability
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerBox(80, 14),
                    _buildShimmerBox(100, 14),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox(double width, double height, {bool isCircular = false}) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height == double.infinity ? null : height,
      decoration: BoxDecoration(
        borderRadius: isCircular 
            ? BorderRadius.circular(height / 2)
            : BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!.withOpacity(0.5 + (_animation.value * 0.5)),
            Colors.grey[300]!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

class ServiceSkeletonCard extends StatelessWidget {
  const ServiceSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          
          // Content skeleton
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Title
                Container(
                  width: 180,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Location
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 140,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Pet type chips
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 50,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
