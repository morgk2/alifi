import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PetProfileSkeleton extends StatelessWidget {
  const PetProfileSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // App Bar Skeleton
            Container(
              height: 100,
              padding: const EdgeInsets.only(top: 40, left: 16),
              child: Row(
                children: [
                  _buildShimmerBox(24, 24, borderRadius: 4),
                ],
              ),
            ),

            // Profile Header Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Profile Picture Skeleton
                  _buildShimmerCircle(120),
                  
                  const SizedBox(height: 16),
                  
                  // Pet Name Skeleton
                  _buildShimmerBox(150, 28, borderRadius: 8),
                  
                  const SizedBox(height: 8),
                  
                  // Followers Count Skeleton
                  _buildShimmerBox(100, 16, borderRadius: 6),
                  
                  const SizedBox(height: 24),
                  
                  // Info Chips Skeleton
                  _buildInfoChipsSkeleton(),
                  
                  const SizedBox(height: 24),
                  
                  // Follow Button Skeleton
                  Center(
                    child: _buildShimmerBox(120, 48, borderRadius: 24),
                  ),
                  
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Photo Grid Skeleton
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: 4, // Show 4 skeleton tiles
                itemBuilder: (context, index) {
                  return _buildPhotoTileSkeleton();
                },
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChipsSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gender skeleton
          Expanded(
            child: Center(child: _buildShimmerBox(50, 16, borderRadius: 6)),
          ),
          // Divider
          Container(
            width: 1,
            height: 18,
            color: Colors.grey.shade300,
          ),
          // Age skeleton
          Expanded(
            child: Center(child: _buildShimmerBox(60, 16, borderRadius: 6)),
          ),
          // Divider
          Container(
            width: 1,
            height: 18,
            color: Colors.grey.shade300,
          ),
          // Breed skeleton
          Expanded(
            child: Center(child: _buildShimmerBox(80, 16, borderRadius: 6)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoTileSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(
            color: Colors.grey.shade200,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBox(double width, double height, {double borderRadius = 8}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  Widget _buildShimmerCircle(double diameter) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}
