import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'skeleton_loader.dart';

class VetCardSkeleton extends StatelessWidget {
  final double width;
  final bool showRanking;

  const VetCardSkeleton({
    super.key,
    this.width = 280,
    this.showRanking = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (showRanking) ...[
                  // Ranking skeleton
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Profile picture skeleton (circle)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey.shade100, width: 2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name skeleton
                      SkeletonLoader(
                        width: 120,
                        height: 16,
                        borderRadius: BorderRadius.circular(8),
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade50,
                      ),
                      const SizedBox(height: 4),
                      // Rating skeleton
                      Row(
                        children: [
                          Icon(CupertinoIcons.star_fill, size: 14, color: Colors.grey.shade300),
                          const SizedBox(width: 4),
                          SkeletonLoader(
                            width: 30,
                            height: 12,
                            borderRadius: BorderRadius.circular(6),
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.grey.shade50,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Location skeleton
            Row(
              children: [
                Icon(CupertinoIcons.location_solid, size: 14, color: Colors.grey.shade300),
                const SizedBox(width: 4),
                Expanded(
                  child: SkeletonLoader(
                    width: 100,
                    height: 12,
                    borderRadius: BorderRadius.circular(6),
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Stats row skeleton
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(CupertinoIcons.person_2_fill, size: 16, color: Colors.grey.shade300),
                      const SizedBox(height: 4),
                      SkeletonLoader(
                        width: 20,
                        height: 10,
                        borderRadius: BorderRadius.circular(5),
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade50,
                      ),
                      const SizedBox(height: 2),
                      SkeletonLoader(
                        width: 40,
                        height: 8,
                        borderRadius: BorderRadius.circular(4),
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade50,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(CupertinoIcons.heart_fill, size: 16, color: Colors.grey.shade300),
                      const SizedBox(height: 4),
                      SkeletonLoader(
                        width: 20,
                        height: 10,
                        borderRadius: BorderRadius.circular(5),
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade50,
                      ),
                      const SizedBox(height: 2),
                      SkeletonLoader(
                        width: 40,
                        height: 8,
                        borderRadius: BorderRadius.circular(4),
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade50,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Subscription badge skeleton
            Center(
              child: SkeletonLoader(
                width: 80,
                height: 20,
                borderRadius: BorderRadius.circular(12),
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VetListCardSkeleton extends StatelessWidget {
  const VetListCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ranking skeleton
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Profile picture skeleton
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade100, width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name skeleton
                SkeletonLoader(
                  width: 120,
                  height: 14,
                  borderRadius: BorderRadius.circular(7),
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade50,
                ),
                const SizedBox(height: 4),
                // Rating and followers skeleton
                Row(
                  children: [
                    Icon(CupertinoIcons.star_fill, size: 12, color: Colors.grey.shade300),
                    const SizedBox(width: 4),
                    SkeletonLoader(
                      width: 25,
                      height: 10,
                      borderRadius: BorderRadius.circular(5),
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                    ),
                    const SizedBox(width: 8),
                    Icon(CupertinoIcons.heart_fill, size: 12, color: Colors.grey.shade300),
                    const SizedBox(width: 4),
                    SkeletonLoader(
                      width: 30,
                      height: 10,
                      borderRadius: BorderRadius.circular(5),
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Location skeleton
                SkeletonLoader(
                  width: 80,
                  height: 10,
                  borderRadius: BorderRadius.circular(5),
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade50,
                ),
              ],
            ),
          ),
          // Subscription badge skeleton
          SkeletonLoader(
            width: 60,
            height: 16,
            borderRadius: BorderRadius.circular(8),
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
          ),
        ],
      ),
    );
  }
}


