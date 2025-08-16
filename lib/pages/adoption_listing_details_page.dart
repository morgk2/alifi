import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/adoption_listing.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../widgets/pinch_zoom_image.dart';
import '../pages/user_profile_page.dart';


class AdoptionListingDetailsPage extends StatefulWidget {
  final AdoptionListing listing;

  const AdoptionListingDetailsPage({
    super.key,
    required this.listing,
  });

  @override
  State<AdoptionListingDetailsPage> createState() => _AdoptionListingDetailsPageState();
}

class _AdoptionListingDetailsPageState extends State<AdoptionListingDetailsPage> {
  User? _owner;
  bool _isLoadingOwner = true;

  @override
  void initState() {
    super.initState();
    print('=== AdoptionListingDetailsPage initState ===');
    print('Listing ID: ${widget.listing.id}');
    print('Listing ownerId: ${widget.listing.ownerId}');
    print('Listing title: ${widget.listing.title}');
    _loadOwnerData();
  }

  Future<void> _loadOwnerData() async {
    try {
      print('=== Loading owner data ===');
      print('Listing ID: ${widget.listing.id}');
      print('Owner ID: ${widget.listing.ownerId}');
      print('Owner ID type: ${widget.listing.ownerId.runtimeType}');
      print('Owner ID length: ${widget.listing.ownerId.length}');
      
      final databaseService = DatabaseService();
      
      // Test if the user ID is valid
      print('Testing user ID validity...');
      if (widget.listing.ownerId.isEmpty) {
        print('ERROR: Owner ID is empty!');
        throw Exception('Owner ID is empty');
      }
      
      // Try to get user with retry mechanism
      User? owner;
      int retryCount = 0;
      const maxRetries = 3;
      
      while (retryCount < maxRetries && owner == null) {
        try {
          print('Attempt ${retryCount + 1} to load owner data...');
          owner = await databaseService.getUser(widget.listing.ownerId);
          
          if (owner != null) {
            print('Owner loaded successfully on attempt ${retryCount + 1}');
            break;
          } else {
            print('Owner is null on attempt ${retryCount + 1}');
            retryCount++;
            if (retryCount < maxRetries) {
              await Future.delayed(Duration(seconds: retryCount)); // Exponential backoff
            }
          }
        } catch (e) {
          print('Error on attempt ${retryCount + 1}: $e');
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount));
          }
        }
      }
      
      print('=== Owner data loaded ===');
      print('Owner object: $owner');
      print('Owner ID: ${owner?.id}');
      print('Owner displayName: ${owner?.displayName}');
      print('Owner email: ${owner?.email}');
      print('Owner photoURL: ${owner?.photoURL}');
      print('Owner basicInfo: ${owner?.basicInfo}');
      
      if (mounted) {
        setState(() {
          _owner = owner;
          _isLoadingOwner = false;
        });
        print('State updated - _owner: $_owner, _isLoadingOwner: $_isLoadingOwner');
        
        // Show success message if owner was loaded
        if (owner != null) {
          print('Owner loaded successfully: ${owner.displayName ?? 'Unknown'}');
        } else {
          print('WARNING: Owner is null after all retry attempts');
          // Show warning to user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not load owner information. The user may have been deleted.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('=== Error loading owner data ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _isLoadingOwner = false;
        });
        
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading owner information: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Enhanced Stretchy Header
          SliverAppBar(
            expandedHeight: 350, // Increased height for better stretchy effect
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            stretch: true, // Enable stretch effect
            stretchTriggerOffset: 100, // Trigger stretch after 100px
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: widget.listing.imageUrls.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PinchZoomImage(
                              imageUrl: widget.listing.imageUrls.first,
                              placeholderPath: 'assets/images/photo_loader.png',
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'adoption_${widget.listing.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(widget.listing.imageUrls.first),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                                stops: const [0.7, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.withOpacity(0.3),
                      child: const Icon(
                        CupertinoIcons.photo,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Basic Info
                                     Text(
                     widget.listing.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                                     Row(
                     children: [
                       _buildInfoChip(widget.listing.petType, CupertinoIcons.paw_solid),
                       const SizedBox(width: 8),
                       _buildInfoChip(widget.listing.breed, CupertinoIcons.tag),
                       const SizedBox(width: 8),
                       _buildInfoChip('${widget.listing.age} years', CupertinoIcons.calendar),
                     ],
                   ),
                  const SizedBox(height: 16),
                  
                  // Description
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                                     Text(
                     widget.listing.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pet Details
                                     _buildSection(
                     'Pet Details',
                     [
                       _buildDetailRow('Type', widget.listing.petType),
                       _buildDetailRow('Breed', widget.listing.breed),
                       _buildDetailRow('Age', '${widget.listing.age} years'),
                       _buildDetailRow('Gender', widget.listing.gender),
                       _buildDetailRow('Color', _getColorName(widget.listing.color)),
                     ],
                   ),
                  const SizedBox(height: 24),

                                     // Requirements
                   if (widget.listing.requirements.isNotEmpty)
                     _buildSection(
                       'Requirements & Documentation',
                       widget.listing.requirements.map((req) => _buildRequirementItem(req)).toList(),
                     ),
                  const SizedBox(height: 24),

                                     // Location
                   _buildSection(
                     'Location',
                     [
                       _buildDetailRow('Address', widget.listing.location),
                     ],
                   ),
                  const SizedBox(height: 24),

                                     // Owner Profile Section
                   Container(
                     padding: const EdgeInsets.all(20),
                     decoration: BoxDecoration(
                       color: Colors.grey.withOpacity(0.05),
                       borderRadius: BorderRadius.circular(16),
                       border: Border.all(color: Colors.grey.withOpacity(0.2)),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             Icon(
                               CupertinoIcons.person_circle,
                               color: Colors.blue,
                               size: 24,
                             ),
                             const SizedBox(width: 12),
                             const Text(
                               'Posted by',
                               style: TextStyle(
                                 fontSize: 18,
                                 fontWeight: FontWeight.w600,
                                 color: Colors.black,
                               ),
                             ),
                           ],
                         ),
                         const SizedBox(height: 16),
                         if (_isLoadingOwner)
                           const Row(
                             children: [
                               CupertinoActivityIndicator(),
                               SizedBox(width: 12),
                               Text('Loading owner information...'),
                             ],
                           )
                         else if (_owner != null)
                           Row(
                             children: [
                               Expanded(
                                 child: GestureDetector(
                                   onTap: () => _navigateToOwnerProfile(),
                                   child: Row(
                                     children: [
                                       CircleAvatar(
                                         radius: 20,
                                         backgroundColor: Colors.blue.withOpacity(0.1),
                                         backgroundImage: _owner!.photoURL != null
                                             ? NetworkImage(_owner!.photoURL!)
                                             : null,
                                         child: _owner!.photoURL == null
                                             ? Text(
                                                 _owner!.displayName?.isNotEmpty == true
                                                     ? _owner!.displayName![0].toUpperCase()
                                                     : 'U',
                                                 style: const TextStyle(
                                                   fontSize: 16,
                                                   fontWeight: FontWeight.bold,
                                                   color: Colors.blue,
                                                 ),
                                               )
                                             : null,
                                       ),
                                       const SizedBox(width: 12),
                                       Expanded(
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: [
                                             Text(
                                               _owner!.displayName ?? 'Unknown User',
                                               style: const TextStyle(
                                                 fontSize: 16,
                                                 fontWeight: FontWeight.w600,
                                                 color: Colors.black,
                                               ),
                                             ),
                                             if (_owner!.basicInfo != null && _owner!.basicInfo!.isNotEmpty)
                                               Text(
                                                 _owner!.basicInfo!,
                                                 style: const TextStyle(
                                                   fontSize: 14,
                                                   color: Colors.grey,
                                                 ),
                                                 maxLines: 2,
                                                 overflow: TextOverflow.ellipsis,
                                               ),
                                           ],
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                               ),
                               const SizedBox(width: 12),
                               CupertinoButton(
                                 onPressed: () => _navigateToOwnerProfile(),
                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                 color: Colors.blue.withOpacity(0.1),
                                 borderRadius: BorderRadius.circular(20),
                                 child: const Text(
                                   'View Profile',
                                   style: TextStyle(
                                     color: Colors.blue,
                                     fontSize: 14,
                                   ),
                                 ),
                               ),
                             ],
                           )
                                                    else
                             Row(
                               children: [
                                 Expanded(
                                   child: GestureDetector(
                                     onTap: () => _showFallbackProfile(),
                                     child: Row(
                                       children: [
                                         CircleAvatar(
                                           radius: 20,
                                           backgroundColor: Colors.grey.withOpacity(0.2),
                                           child: Text(
                                             'U',
                                             style: const TextStyle(
                                               fontSize: 16,
                                               fontWeight: FontWeight.bold,
                                               color: Colors.grey,
                                             ),
                                           ),
                                         ),
                                         const SizedBox(width: 12),
                                         Expanded(
                                           child: Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                               const Text(
                                                 'Unknown User',
                                                 style: TextStyle(
                                                   fontSize: 16,
                                                   fontWeight: FontWeight.w600,
                                                   color: Colors.grey,
                                                 ),
                                               ),
                                               Text(
                                                 'Owner ID: ${widget.listing.ownerId}',
                                                 style: const TextStyle(
                                                   fontSize: 12,
                                                   color: Colors.grey,
                                                 ),
                                               ),
                                             ],
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ),
                                 const SizedBox(width: 12),
                                 CupertinoButton(
                                   onPressed: () => _loadOwnerData(),
                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                   color: Colors.orange.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(20),
                                   child: const Text(
                                     'Retry',
                                     style: TextStyle(
                                       color: Colors.orange,
                                       fontSize: 14,
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                       ],
                     ),
                   ),
                   
                   const SizedBox(height: 16),
                   
                   // Contact Section
                   Container(
                     padding: const EdgeInsets.all(20),
                     decoration: BoxDecoration(
                       color: Colors.orange.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(16),
                       border: Border.all(color: Colors.orange.withOpacity(0.3)),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             Icon(
                               CupertinoIcons.chat_bubble_2,
                               color: Colors.orange,
                               size: 24,
                             ),
                             const SizedBox(width: 12),
                             const Text(
                               'Contact Owner',
                               style: TextStyle(
                                 fontSize: 18,
                                 fontWeight: FontWeight.w600,
                                 color: Colors.black,
                               ),
                             ),
                           ],
                         ),
                         const SizedBox(height: 16),
                         Row(
                           children: [
                             Expanded(
                               child: CupertinoButton(
                                 onPressed: () => _contactOwner(widget.listing.contactNumber),
                                 color: Colors.orange,
                                 borderRadius: BorderRadius.circular(25),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     const Icon(
                                       CupertinoIcons.phone,
                                       color: Colors.white,
                                       size: 20,
                                     ),
                                     const SizedBox(width: 8),
                                     Text(
                                       'Call ${widget.listing.contactNumber}',
                                       style: const TextStyle(
                                         color: Colors.white,
                                         fontSize: 16,
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                             if (_owner != null) ...[
                               const SizedBox(width: 12),
                               Expanded(
                                 child: CupertinoButton(
                                   onPressed: () => _startChat(),
                                   color: Colors.green,
                                   borderRadius: BorderRadius.circular(25),
                                   child: Row(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       const Icon(
                                         CupertinoIcons.chat_bubble_2,
                                         color: Colors.white,
                                         size: 20,
                                       ),
                                       const SizedBox(width: 8),
                                       const Text(
                                         'Message',
                                         style: TextStyle(
                                           color: Colors.white,
                                           fontSize: 16,
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                               ),
                             ],
                           ],
                         ),
                       ],
                     ),
                   ),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String requirement) {
    bool isPositive = requirement.toLowerCase().contains('good') ||
                     requirement.toLowerCase().contains('vaccinated') ||
                     requirement.toLowerCase().contains('trained') ||
                     requirement.toLowerCase().contains('microchipped') ||
                     requirement.toLowerCase().contains('neutered');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.info_circle_fill,
            color: isPositive ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              requirement,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    final hexMatch = RegExp(r'0x[a-fA-F0-9]{8}').firstMatch(colorString);
    if (hexMatch != null) {
      return Color(int.parse(hexMatch.group(0)!));
    }
    return const Color(0xFFF59E0B);
  }

  String _getColorName(String colorHex) {
    final color = _parseColor(colorHex);
    if (color == Colors.black) return 'Black';
    if (color == Colors.white) return 'White';
    if (color == Colors.brown) return 'Brown';
    if (color == Colors.grey) return 'Grey';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.yellow) return 'Yellow';
    if (color == Colors.red) return 'Red';
    if (color == Colors.blue) return 'Blue';
    return 'Mixed';
  }

  void _navigateToOwnerProfile() {
    print('=== Navigating to owner profile ===');
    print('Owner: $_owner');
    print('Owner ID: ${_owner?.id}');
    print('Owner displayName: ${_owner?.displayName}');
    
    if (_owner != null) {
      try {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserProfilePage(user: _owner!),
          ),
        );
        print('Navigation successful');
      } catch (e) {
        print('Navigation error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('Owner is null, cannot navigate');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Owner information not available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showFallbackProfile() {
    print('=== Showing fallback profile ===');
    print('Owner ID: ${widget.listing.ownerId}');
    
    // Create a temporary user object for the fallback profile
    final tempUser = User(
      id: widget.listing.ownerId,
      email: 'unknown@example.com',
      displayName: 'Unknown User',
      username: null,
      photoURL: null,
      coverPhotoURL: null,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      linkedAccounts: {},
      isAdmin: false,
      accountType: 'normal',
      isVerified: false,
      basicInfo: 'This user profile is currently unavailable.',
      patients: null,
      rating: 0.0,
      totalOrders: 0,
      pets: null,
      followers: [],
      following: [],
      followersCount: 0,
      followingCount: 0,
      searchTokens: [],
      products: null,
      location: null,
      reviews: null,
      defaultAddress: null,
      addresses: null,
      dailyRevenue: 0.0,
      totalRevenue: 0.0,
      lastRevenueUpdate: null,
      subscriptionPlan: null,
      subscriptionStatus: null,
      subscriptionStartDate: null,
      nextBillingDate: null,
      lastBillingDate: null,
      paymentMethod: null,
      subscriptionAmount: null,
      subscriptionCurrency: null,
      subscriptionInterval: null,
      businessFirstName: null,
      businessLastName: null,
      businessName: null,
      businessLocation: null,
      city: null,
      phone: null,
      clinicName: null,
      clinicLocation: null,
      storeName: null,
      storeLocation: null,
    );
    
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UserProfilePage(user: tempUser),
        ),
      );
    } catch (e) {
      print('Error navigating to fallback profile: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('User Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This user profile is currently unavailable.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'User ID: ${widget.listing.ownerId}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This could be because:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• The user has deleted their account'),
                const Text('• There was a temporary network issue'),
                const Text('• The user ID is invalid'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _loadOwnerData();
                },
                child: const Text('Retry'),
              ),
            ],
          );
        },
      );
    }
  }

  void _startChat() {
    if (_owner != null) {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.currentUser != null) {
        // Navigate to messages page with the owner
        Navigator.of(context).pushNamed(
          '/messages',
          arguments: {
            'recipientId': _owner!.id,
                                           'recipientName': _owner!.displayName ?? 'Unknown User',
          },
        );
      }
    }
  }

  Future<void> _contactOwner(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
