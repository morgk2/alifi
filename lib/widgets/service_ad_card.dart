import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/service_ad.dart';
import '../utils/app_fonts.dart';
import '../services/navigation_service.dart';
import '../pages/service_ad_detail_page.dart';

class ServiceAdCard extends StatelessWidget {
  final ServiceAd serviceAd;
  final VoidCallback? onTap;

  const ServiceAdCard({
    super.key,
    required this.serviceAd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final serviceColor = serviceAd.serviceType == ServiceAdType.grooming 
        ? Colors.orange 
        : Colors.blue;

    return GestureDetector(
      onTap: onTap ?? () => _showAdDetail(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ad Image Section
            if (serviceAd.imageUrl != null && serviceAd.imageUrl!.isNotEmpty)
              _buildAdImage(context, serviceColor),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Profile Picture and Service Type Badge
                  _buildHeader(context, serviceColor),
                  
                  const SizedBox(height: 12),
                  
                  // Service Title
                  _buildTitle(context),
                  
                  const SizedBox(height: 8),
                  
                  // Location
                  _buildLocation(context),
                  
                  const SizedBox(height: 12),
                  
                  // Pet Types
                  _buildPetTypes(context, serviceColor),
                  
                  const SizedBox(height: 12),
                  
                  // Footer with Rating and Availability
                  _buildFooter(context, serviceColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdImage(BuildContext context, Color serviceColor) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        color: Colors.grey[100],
      ),
      child: Stack(
        children: [
          // Main Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: CachedNetworkImage(
              imageUrl: serviceAd.imageUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: Center(
                  child: CupertinoActivityIndicator(color: serviceColor),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Center(
                  child: Icon(
                    CupertinoIcons.photo,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),
          
          // Service Type Badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: serviceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    serviceAd.serviceType == ServiceAdType.grooming
                        ? CupertinoIcons.scissors_alt
                        : CupertinoIcons.person_2_alt,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    serviceAd.serviceType == ServiceAdType.grooming
                        ? 'Grooming'
                        : 'Training',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color serviceColor) {
    return Row(
      children: [
        // Profile Picture
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: serviceColor.withOpacity(0.3), width: 2),
          ),
          child: ClipOval(
            child: serviceAd.userProfileImage.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: serviceAd.userProfileImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: Icon(
                        CupertinoIcons.person_fill,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Icon(
                        CupertinoIcons.person_fill,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                : Container(
                    color: serviceColor.withOpacity(0.1),
                    child: Icon(
                      CupertinoIcons.person_fill,
                      size: 20,
                      color: serviceColor,
                    ),
                  ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // User Name and Time
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serviceAd.userName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: AppFonts.getTitleFontFamily(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _formatTimeAgo(serviceAd.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: AppFonts.getLocalizedFontFamily(context),
                ),
              ),
            ],
          ),
        ),
        
        // Rating if available
        if (serviceAd.rating > 0) ...[
          Icon(
            CupertinoIcons.star_fill,
            size: 14,
            color: Colors.amber,
          ),
          const SizedBox(width: 4),
          Text(
            serviceAd.rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontFamily: AppFonts.getLocalizedFontFamily(context),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      serviceAd.serviceName,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black,
        fontFamily: AppFonts.getTitleFontFamily(context),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocation(BuildContext context) {
    return Row(
      children: [
        Icon(
          CupertinoIcons.location,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            serviceAd.locationAddress,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontFamily: AppFonts.getLocalizedFontFamily(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPetTypes(BuildContext context, Color serviceColor) {
    final displayPetTypes = serviceAd.petTypes.take(3).toList();
    final hasMore = serviceAd.petTypes.length > 3;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        ...displayPetTypes.map((petType) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: serviceColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: serviceColor.withOpacity(0.3)),
          ),
          child: Text(
            petType,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: serviceColor.withOpacity(0.8),
              fontFamily: AppFonts.getLocalizedFontFamily(context),
            ),
          ),
        )),
        if (hasMore)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              '+${serviceAd.petTypes.length - 3}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontFamily: AppFonts.getLocalizedFontFamily(context),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, Color serviceColor) {
    return Row(
      children: [
        // Availability Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: serviceAd.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: serviceAd.isActive ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                serviceAd.isActive ? 'Available' : 'Unavailable',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: serviceAd.isActive ? Colors.green[700] : Colors.grey[600],
                  fontFamily: AppFonts.getLocalizedFontFamily(context),
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Available Days Count
        Icon(
          CupertinoIcons.calendar,
          size: 12,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          '${serviceAd.availableDays.length} days/week',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontFamily: AppFonts.getLocalizedFontFamily(context),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // View Details Arrow
        Icon(
          CupertinoIcons.chevron_right,
          size: 14,
          color: serviceColor,
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showAdDetail(BuildContext context) {
    NavigationService.push(
      context,
      ServiceAdDetailPage(serviceAd: serviceAd),
    );
  }
}
