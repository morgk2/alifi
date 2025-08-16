import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/service_ad.dart';
import '../services/service_ad_service.dart';
import '../services/navigation_service.dart';
import '../utils/app_fonts.dart';
import '../pages/post_service_ad_page.dart';
import '../pages/service_ad_detail_page.dart';

class UserAdsDialog extends StatefulWidget {
  final ServiceAdType serviceType;

  const UserAdsDialog({
    super.key,
    required this.serviceType,
  });

  @override
  State<UserAdsDialog> createState() => _UserAdsDialogState();
}

class _UserAdsDialogState extends State<UserAdsDialog> {
  List<ServiceAd> _userAds = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserAds();
  }

  Future<void> _loadUserAds() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final userId = await _getCurrentUserId();
      if (userId != null) {
        final allUserAds = await ServiceAdService.getUserServiceAds(userId);
        final filteredAds = allUserAds.where((ad) => ad.serviceType == widget.serviceType).toList();
        
        if (mounted) {
          setState(() {
            _userAds = filteredAds;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _getCurrentUserId() async {
    // This should get the current user ID from Firebase Auth
    try {
      final user = await ServiceAdService.getCurrentUser();
      return user?.uid;
    } catch (e) {
      return null;
    }
  }

  String get _serviceTitle {
    switch (widget.serviceType) {
      case ServiceAdType.training:
        return 'Training Ads';
      case ServiceAdType.grooming:
        return 'Grooming Ads';
    }
  }

  Color get _serviceColor {
    switch (widget.serviceType) {
      case ServiceAdType.training:
        return Colors.blue;
      case ServiceAdType.grooming:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _serviceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.serviceType == ServiceAdType.training
                  ? CupertinoIcons.person_2_alt
                  : CupertinoIcons.scissors_alt,
              color: _serviceColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My $_serviceTitle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontFamily: AppFonts.getTitleFontFamily(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage your service advertisements',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.xmark,
                size: 18,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_userAds.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadUserAds,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _userAds.length,
        itemBuilder: (context, index) {
          return _buildAdCard(_userAds[index]);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(
            color: _serviceColor,
            radius: 20,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your ads...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: AppFonts.getLocalizedFontFamily(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 60,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Ads',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: AppFonts.getTitleFontFamily(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: AppFonts.getLocalizedFontFamily(context),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUserAds,
              icon: Icon(CupertinoIcons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _serviceColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.serviceType == ServiceAdType.training
                  ? CupertinoIcons.person_2_alt
                  : CupertinoIcons.scissors_alt,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Ads Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontFamily: AppFonts.getTitleFontFamily(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t posted any ${widget.serviceType.name} ads yet. Create your first ad to start connecting with pet owners!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
                fontFamily: AppFonts.getLocalizedFontFamily(context),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _createNewAd(),
                icon: Icon(CupertinoIcons.add_circled, size: 20),
                label: Text('Create Ad'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _serviceColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdCard(ServiceAd ad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _viewAdDetail(ad),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Ad Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[100],
                  child: ad.imageUrl != null && ad.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: ad.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              CupertinoIcons.photo,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              CupertinoIcons.photo,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                          ),
                        )
                      : Icon(
                          CupertinoIcons.photo,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Ad Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.serviceName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: AppFonts.getTitleFontFamily(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ad.locationAddress,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontFamily: AppFonts.getLocalizedFontFamily(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ad.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ad.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ad.isActive ? Colors.green : Colors.grey[600],
                              fontFamily: AppFonts.getLocalizedFontFamily(context),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(ad.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontFamily: AppFonts.getLocalizedFontFamily(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Actions Menu
              GestureDetector(
                onTap: () => _showAdActions(ad),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    CupertinoIcons.ellipsis_vertical,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _viewAdDetail(ServiceAd ad) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => ServiceAdDetailPage(serviceAd: ad),
      ),
    );
  }

  void _showAdActions(ServiceAd ad) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(
            ad.serviceName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.getLocalizedFontFamily(context),
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _editAd(ad);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.pencil,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Ad',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                    ),
                  ),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _toggleAdStatus(ad);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ad.isActive ? CupertinoIcons.pause : CupertinoIcons.play,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ad.isActive ? 'Deactivate' : 'Activate',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                    ),
                  ),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _confirmDeleteAd(ad);
              },
              isDestructiveAction: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.delete,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Delete Ad',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.getLocalizedFontFamily(context),
              ),
            ),
          ),
        );
      },
    );
  }

  void _createNewAd() async {
    Navigator.of(context).pop(); // Close dialog first
    
    final result = await NavigationService.push(
      context,
      PostServiceAdPage(serviceType: widget.serviceType),
    );
    
    // If we return to this dialog, we should refresh
    if (result != null) {
      _loadUserAds();
    }
  }

  void _editAd(ServiceAd ad) async {
    // For now, navigate to the same post page but with pre-filled data
    // You might want to create a separate edit page or modify PostServiceAdPage
    Navigator.of(context).pop(); // Close dialog first
    
    final result = await NavigationService.push(
      context,
      PostServiceAdPage(
        serviceType: widget.serviceType,
        existingAd: ad, // You'll need to add this parameter to PostServiceAdPage
      ),
    );
    
    if (result != null) {
      _loadUserAds();
    }
  }

  void _toggleAdStatus(ServiceAd ad) async {
    try {
      await ServiceAdService.toggleAdActiveStatus(ad.id, !ad.isActive);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ad.isActive ? 'Ad deactivated successfully' : 'Ad activated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadUserAds(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDeleteAd(ServiceAd ad) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            'Delete Ad',
            style: TextStyle(
              fontFamily: AppFonts.getTitleFontFamily(context),
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${ad.serviceName}"? This action cannot be undone and will also remove the associated photo.',
            style: TextStyle(
              fontFamily: AppFonts.getLocalizedFontFamily(context),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: AppFonts.getLocalizedFontFamily(context),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text(
                'Delete',
                style: TextStyle(
                  fontFamily: AppFonts.getLocalizedFontFamily(context),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAd(ad);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAd(ServiceAd ad) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CupertinoActivityIndicator(color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text('Deleting ad and photo...'),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }

      await ServiceAdService.deleteServiceAd(ad.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ad deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadUserAds(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting ad: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
