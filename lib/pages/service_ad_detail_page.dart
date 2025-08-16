import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/service_ad.dart';
import '../utils/app_fonts.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/navigation_service.dart';
import '../pages/service_ad_chat_page.dart';

class ServiceAdDetailPage extends StatefulWidget {
  final ServiceAd serviceAd;

  const ServiceAdDetailPage({
    super.key,
    required this.serviceAd,
  });

  @override
  State<ServiceAdDetailPage> createState() => _ServiceAdDetailPageState();
}

class _ServiceAdDetailPageState extends State<ServiceAdDetailPage> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final serviceColor = widget.serviceAd.serviceType == ServiceAdType.grooming 
        ? Colors.orange 
        : Colors.blue;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          _buildSliverAppBar(serviceColor),
          
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Header
                _buildServiceHeader(serviceColor),
                
                // Description
                _buildDescriptionSection(),
                
                // Availability
                _buildAvailabilitySection(serviceColor),
                
                // Pet Types
                _buildPetTypesSection(serviceColor),
                
                // Location & Map
                _buildLocationSection(serviceColor),
                
                // Contact Actions
                _buildContactActions(serviceColor),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Color serviceColor) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            CupertinoIcons.back,
            color: Colors.black,
            size: 20,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => _shareAd(),
            icon: Icon(
              CupertinoIcons.share,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: widget.serviceAd.imageUrl != null && widget.serviceAd.imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: widget.serviceAd.imageUrl!,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.serviceAd.serviceType == ServiceAdType.grooming
                              ? CupertinoIcons.scissors_alt
                              : CupertinoIcons.person_2_alt,
                          size: 60,
                          color: serviceColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.serviceAd.serviceType == ServiceAdType.grooming
                              ? 'Grooming Service'
                              : 'Training Service',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: serviceColor,
                            fontFamily: AppFonts.getTitleFontFamily(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(
                color: serviceColor.withOpacity(0.1),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.serviceAd.serviceType == ServiceAdType.grooming
                            ? CupertinoIcons.scissors_alt
                            : CupertinoIcons.person_2_alt,
                        size: 60,
                        color: serviceColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.serviceAd.serviceType == ServiceAdType.grooming
                            ? 'Grooming Service'
                            : 'Training Service',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: serviceColor,
                          fontFamily: AppFonts.getTitleFontFamily(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildServiceHeader(Color serviceColor) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Provider Info
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: serviceColor.withOpacity(0.3), width: 2),
                ),
                child: ClipOval(
                  child: widget.serviceAd.userProfileImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.serviceAd.userProfileImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              CupertinoIcons.person_fill,
                              size: 24,
                              color: Colors.grey[400],
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              CupertinoIcons.person_fill,
                              size: 24,
                              color: Colors.grey[400],
                            ),
                          ),
                        )
                      : Container(
                          color: serviceColor.withOpacity(0.1),
                          child: Icon(
                            CupertinoIcons.person_fill,
                            size: 24,
                            color: serviceColor,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.serviceAd.userName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: AppFonts.getTitleFontFamily(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: serviceColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.serviceAd.serviceType == ServiceAdType.grooming
                                    ? CupertinoIcons.scissors_alt
                                    : CupertinoIcons.person_2_alt,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.serviceAd.serviceType == ServiceAdType.grooming
                                    ? 'Groomer'
                                    : 'Trainer',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.serviceAd.rating > 0) ...[
                          const SizedBox(width: 8),
                          Icon(
                            CupertinoIcons.star_fill,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.serviceAd.rating.toStringAsFixed(1)} (${widget.serviceAd.reviewCount})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              fontFamily: AppFonts.getLocalizedFontFamily(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Service Title
          Text(
            widget.serviceAd.serviceName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: AppFonts.getTitleFontFamily(context),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Posted Time
          Text(
            'Posted ${_formatTimeAgo(widget.serviceAd.createdAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: AppFonts.getLocalizedFontFamily(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.doc_text,
                size: 20,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: AppFonts.getTitleFontFamily(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.serviceAd.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
              fontFamily: AppFonts.getLocalizedFontFamily(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(Color serviceColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.clock,
                size: 20,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Availability',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: AppFonts.getTitleFontFamily(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Available Days
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
            ].map((day) {
              final isAvailable = widget.serviceAd.availableDays.contains(day);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAvailable ? serviceColor.withOpacity(0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAvailable ? serviceColor.withOpacity(0.5) : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  day.substring(0, 3),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isAvailable ? serviceColor : Colors.grey[600],
                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 12),
          
          // Available Hours
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: serviceColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.time,
                  size: 16,
                  color: serviceColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Available from ${widget.serviceAd.startTime} to ${widget.serviceAd.endTime}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: serviceColor,
                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetTypesSection(Color serviceColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.paw,
                size: 20,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Pet Types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: AppFonts.getTitleFontFamily(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.serviceAd.petTypes.map((petType) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: serviceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: serviceColor.withOpacity(0.3)),
              ),
              child: Text(
                petType,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: serviceColor,
                  fontFamily: AppFonts.getLocalizedFontFamily(context),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(Color serviceColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.location,
                size: 20,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: AppFonts.getTitleFontFamily(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.serviceAd.locationAddress,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontFamily: AppFonts.getLocalizedFontFamily(context),
            ),
          ),
          const SizedBox(height: 16),
          
          // Map
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(widget.serviceAd.latitude, widget.serviceAd.longitude),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.alifi',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(widget.serviceAd.latitude, widget.serviceAd.longitude),
                        width: 40,
                        height: 40,
                        child: Icon(
                          CupertinoIcons.location_fill,
                          color: serviceColor,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactActions(Color serviceColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact ${widget.serviceAd.userName}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: AppFonts.getTitleFontFamily(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _contactProvider(),
                  icon: Icon(CupertinoIcons.chat_bubble_fill, size: 18),
                  label: Text('Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: serviceColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openInMaps(),
                  icon: Icon(CupertinoIcons.location, size: 18),
                  label: Text('View on Map'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: serviceColor,
                    side: BorderSide(color: serviceColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _shareAd() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _contactProvider() async {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please sign in to send messages'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Don't allow messaging yourself
    if (currentUser.id == widget.serviceAd.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You cannot message yourself'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Get the service provider's user details
      final providerUser = await DatabaseService().getUser(widget.serviceAd.userId);
      if (providerUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to find service provider'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (mounted) {
        // Navigate to service ad chat page with the ad as attachment
        NavigationService.push(
          context,
          ServiceAdChatPage(
            providerUser: providerUser,
            serviceAd: widget.serviceAd,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening chat: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openInMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${widget.serviceAd.latitude},${widget.serviceAd.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
