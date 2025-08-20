import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'skeleton_loader.dart';

class GroomerSkeletonLoader extends StatelessWidget {
  const GroomerSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // Service Icon Banner Skeleton
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Section Title Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(
                        width: 180,
                        height: 18,
                        borderRadius: BorderRadius.circular(9),
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade50,
                      ),
                      const SizedBox(height: 4),
                      SkeletonLoader(
                        width: 160,
                        height: 13,
                        borderRadius: BorderRadius.circular(6),
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade50,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SkeletonLoader(
                  width: 60,
                  height: 14,
                  borderRadius: BorderRadius.circular(7),
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade50,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Service Cards Skeleton
          ...List.generate(4, (index) => _buildGroomerServiceCardSkeleton()),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGroomerServiceCardSkeleton() {
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
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                // Service type badge skeleton
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: SkeletonLoader(
                      width: 60,
                      height: 16,
                      borderRadius: BorderRadius.circular(8),
                      baseColor: Colors.orange.withOpacity(0.2),
                      highlightColor: Colors.orange.withOpacity(0.1),
                    ),
                  ),
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
                    // Profile image skeleton
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Name and date skeleton
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLoader(
                            width: 100,
                            height: 16,
                            borderRadius: BorderRadius.circular(8),
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.grey.shade50,
                          ),
                          const SizedBox(height: 4),
                          SkeletonLoader(
                            width: 80,
                            height: 12,
                            borderRadius: BorderRadius.circular(6),
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.grey.shade50,
                          ),
                        ],
                      ),
                    ),
                    
                    // Rating skeleton
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.star_fill,
                          size: 14,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 4),
                        SkeletonLoader(
                          width: 30,
                          height: 14,
                          borderRadius: BorderRadius.circular(7),
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.grey.shade50,
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Service title skeleton
                SkeletonLoader(
                  width: 180,
                  height: 20,
                  borderRadius: BorderRadius.circular(10),
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade50,
                ),
                
                const SizedBox(height: 8),
                
                // Description skeleton
                SkeletonLoader(
                  width: double.infinity,
                  height: 14,
                  borderRadius: BorderRadius.circular(7),
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade50,
                ),
                const SizedBox(height: 4),
                SkeletonLoader(
                  width: 160,
                  height: 14,
                  borderRadius: BorderRadius.circular(7),
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade50,
                ),
                
                const SizedBox(height: 12),
                
                // Location skeleton
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.location_solid,
                      size: 14,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 6),
                    SkeletonLoader(
                      width: 120,
                      height: 14,
                      borderRadius: BorderRadius.circular(7),
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Pet types chips skeleton
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SkeletonLoader(
                        width: 40,
                        height: 16,
                        borderRadius: BorderRadius.circular(8),
                        baseColor: Colors.orange.withOpacity(0.2),
                        highlightColor: Colors.orange.withOpacity(0.1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SkeletonLoader(
                        width: 30,
                        height: 16,
                        borderRadius: BorderRadius.circular(8),
                        baseColor: Colors.orange.withOpacity(0.2),
                        highlightColor: Colors.orange.withOpacity(0.1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SkeletonLoader(
                        width: 50,
                        height: 16,
                        borderRadius: BorderRadius.circular(8),
                        baseColor: Colors.orange.withOpacity(0.2),
                        highlightColor: Colors.orange.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Footer with price and availability skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(
                          width: 60,
                          height: 12,
                          borderRadius: BorderRadius.circular(6),
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.grey.shade50,
                        ),
                        const SizedBox(height: 4),
                        SkeletonLoader(
                          width: 80,
                          height: 16,
                          borderRadius: BorderRadius.circular(8),
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.grey.shade50,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SkeletonLoader(
                        width: 60,
                        height: 14,
                        borderRadius: BorderRadius.circular(7),
                        baseColor: Colors.green.withOpacity(0.2),
                        highlightColor: Colors.green.withOpacity(0.1),
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

