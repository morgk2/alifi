import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../models/adoption_listing.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/geocoding_service.dart';
import '../widgets/spinning_loader.dart';
import '../dialogs/add_adoption_listing_dialog.dart';
import '../dialogs/my_listings_dialog.dart';
import '../pages/adoption_listing_details_page.dart';
import '../pages/adoption_filter_page.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_fonts.dart';

class AdoptionCenterPage extends StatefulWidget {
  const AdoptionCenterPage({super.key});

  @override
  State<AdoptionCenterPage> createState() => _AdoptionCenterPageState();
}

class _AdoptionCenterPageState extends State<AdoptionCenterPage> {
  final _databaseService = DatabaseService();
  Map<String, dynamic>? _currentFilters;
  String _userAddress = '';
  bool _isLoadingLocation = true;
  latlong.LatLng? _userLocation;
  bool _isSearchExpanded = false;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Color _parseColor(String colorString) {
    final hexMatch = RegExp(r'0x[a-fA-F0-9]{8}').firstMatch(colorString);
    if (hexMatch != null) {
      return Color(int.parse(hexMatch.group(0)!));
    }
    return const Color(0xFFF59E0B);
  }

  Widget _buildAdoptionCircle(AdoptionListing listing) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AdoptionListingDetailsPage(listing: listing),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _parseColor(listing.color),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: listing.imageUrls.isNotEmpty
                  ? Image.network(
                      listing.imageUrls.first,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.pets,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            listing.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Image.asset(
                        'assets/images/back_icon.png',
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/adoption.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.adoptionCenter,
                            style: TextStyle(fontFamily: context.titleFont,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        size: 28,
                        color: Colors.orange,
                      ),
                      onPressed: () {
                        _showAddListingDialog(l10n);
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        size: 28,
                        color: Colors.orange,
                      ),
                      onPressed: () {
                        _showMyListingsDialog(l10n);
                      },
                    ),
                  ],
                ),
              ),
                          const SizedBox(height: 24), // Added spacing
            
            // User location section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Location',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (_isLoadingLocation)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: _getUserLocation,
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                      tooltip: 'Refresh location',
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Pets near me section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                                                                    // Title and Search Container
                       Expanded(
                         child: _isSearchExpanded
                             ? AnimatedOpacity(
                                 duration: const Duration(milliseconds: 300),
                                 opacity: _isSearchExpanded ? 1.0 : 0.0,
                                 child: Container(
                                   height: 40,
                                   decoration: BoxDecoration(
                                     color: Colors.grey[100],
                                     borderRadius: BorderRadius.circular(20),
                                   ),
                                   padding: const EdgeInsets.symmetric(horizontal: 16),
                                   child: Row(
                                     children: [
                                       const Icon(Icons.search, color: Colors.grey, size: 20),
                                       const SizedBox(width: 12),
                                       Expanded(
                                         child: TextField(
                                           controller: _searchController,
                                           focusNode: _searchFocusNode,
                                           decoration: InputDecoration(
                                             hintText: l10n.searchPets,
                                             border: InputBorder.none,
                                             isDense: true,
                                           ),
                                           style: const TextStyle(fontSize: 14),
                                           onChanged: (value) {
                                             setState(() {
                                               _searchQuery = value;
                                               _isSearching = value.isNotEmpty;
                                             });
                                           },
                                           onSubmitted: (value) {
                                             setState(() {
                                               _searchQuery = value;
                                               _isSearching = value.isNotEmpty;
                                             });
                                           },
                                         ),
                                       ),
                                                                                GestureDetector(
                                           onTap: () {
                                             setState(() {
                                               _isSearchExpanded = false;
                                               _searchController.clear();
                                               _searchQuery = '';
                                               _isSearching = false;
                                             });
                                             _searchFocusNode.unfocus();
                                           },
                                           child: const Icon(Icons.close, color: Colors.grey, size: 18),
                                         ),
                                     ],
                                   ),
                                 ),
                               )
                             : AnimatedOpacity(
                                 duration: const Duration(milliseconds: 300),
                                 opacity: _isSearchExpanded ? 0.0 : 1.0,
                                 child: Row(
                                   children: [
                                     const Icon(Icons.star, size: 24),
                                     const SizedBox(width: 8),
                                     Text(
                                       l10n.petsNearMe,
                                       style: TextStyle(
                                         fontSize: 18,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                       ),
                                             const SizedBox(width: 8),
                       // Search Button
                       IconButton(
                         icon: const Icon(Icons.search),
                         style: IconButton.styleFrom(
                           backgroundColor: Colors.grey[100],
                           padding: const EdgeInsets.all(8),
                         ),
                         onPressed: () {
                           setState(() {
                             _isSearchExpanded = true;
                           });
                           Future.delayed(const Duration(milliseconds: 100), () {
                             _searchFocusNode.requestFocus();
                           });
                         },
                       ),
                       const SizedBox(width: 8),
                       Stack(
                         children: [
                           IconButton(
                             icon: const Icon(Icons.tune),
                             style: IconButton.styleFrom(
                               backgroundColor: _currentFilters != null && _getActiveFilterCount() > 0 
                                   ? Colors.orange[100] 
                                   : Colors.grey[100],
                               padding: const EdgeInsets.all(8),
                             ),
                             onPressed: () {
                               _showFilterPage(l10n);
                             },
                           ),
                          if (_currentFilters != null && _getActiveFilterCount() > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${_getActiveFilterCount()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                                     const SizedBox(height: 4),
                   Text(
                     l10n.basedOnYourCurrentLocation,
                     style: TextStyle(
                       fontSize: 12,
                       color: Colors.grey[600],
                       fontStyle: FontStyle.italic,
                     ),
                   ),
                ],
              ),
            ),
              const SizedBox(height: 16),
                          // Pets near me horizontal list
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: 1.0,
              child: SizedBox(
                height: 140,
                child: StreamBuilder<List<AdoptionListing>>(
                  stream: _databaseService.getAdoptionListings(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('${l10n.error}: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: SpinningLoader(color: Colors.orange));
                    }

                    final listings = snapshot.data!;
                    final filteredListings = _applyFiltersExcludingLocation(listings);
                    
                                          if (filteredListings.isEmpty) {
                        return _buildNoPetsNearMeState(l10n);
                      }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredListings.length,
                      itemBuilder: (context, index) {
                        final listing = filteredListings[index];
                        return _buildAdoptionCircle(listing);
                      },
                    );
                  },
                ),
              ),
            ),
              const SizedBox(height: 32), // Increased spacing
              // New listings section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          l10n.newListings,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Text(
                            l10n.seeAll,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // New listings grid
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5, // Fixed height for grid
                  child: StreamBuilder<List<AdoptionListing>>(
                    stream: _databaseService.getAdoptionListings(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('${l10n.error}: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: SpinningLoader(color: Colors.orange));
                      }

                      final listings = snapshot.data!;
                      final filteredListings = _applyFilters(listings);
                      
                      if (filteredListings.isEmpty) {
                        return _buildNoResultsState(l10n);
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredListings.length,
                        itemBuilder: (context, index) {
                          final listing = filteredListings[index];
                          return _buildAdoptionCircle(listing);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.pets,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noAdoptionListingsYet,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.beTheFirstToAddPetForAdoption,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showAddListingDialog(l10n);
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.addListing),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPetsNearMeState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.location_off,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noPetsNearMe,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.noAdoptionListingsInYourArea,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddListingDialog(AppLocalizations l10n) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddAdoptionListingDialog(),
      ),
    );
  }

  void _showMyListingsDialog(AppLocalizations l10n) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseLoginToManageListings),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => MyListingsDialog(userId: currentUser.id),
    );
  }

  void _showFilterPage(AppLocalizations l10n) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdoptionFilterPage(currentFilters: _currentFilters),
      ),
    );
    
    if (result != null && mounted) {
      setState(() {
        _currentFilters = result;
      });
      
      // Show a snackbar to indicate filters have been applied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.filtersApplied(_getActiveFilterCount())),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  int _getActiveFilterCount() {
    if (_currentFilters == null) return 0;
    
    int count = 0;
    final filters = _currentFilters!;
    
    if (filters['petType'] != 'All') count++;
    if (filters['breed'] != 'All') count++;
    if (filters['gender'] != 'All') count++;
    if (filters['ageRange'] != 'All') count++;
    if (filters['priceRange'] != 'All') count++;
    if (filters['location'] != 'All') count++;
    if (filters['onlyActive'] == true) count++;
    if (filters['onlyWithPhotos'] == true) count++;
    
    return count;
  }

  Future<void> _getUserLocation([AppLocalizations? l10n]) async {
    try {
      setState(() {
        _isLoadingLocation = true;
        _userAddress = l10n?.gettingYourLocation ?? 'Getting your location...';
      });

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
            _userAddress = l10n?.locationPermissionDenied ?? 'Location permission denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
                      _userAddress = l10n?.locationPermissionPermanentlyDenied ?? 'Location permission permanently denied';
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _userLocation = latlong.LatLng(position.latitude, position.longitude);
        });

        // Get address from coordinates
        final address = await GeocodingService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (mounted) {
          setState(() {
            _userAddress = address;
            _isLoadingLocation = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
                      _userAddress = l10n?.unableToGetLocation ?? 'Unable to get location';
        });
      }
      print('Error getting user location: $e');
    }
  }

  List<AdoptionListing> _applyFilters(List<AdoptionListing> listings) {
    List<AdoptionListing> filteredListings = List.from(listings);
    
    // Apply search query filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredListings = filteredListings.where((listing) {
        return listing.title.toLowerCase().contains(query) ||
               listing.description.toLowerCase().contains(query) ||
               listing.petType.toLowerCase().contains(query) ||
               listing.breed.toLowerCase().contains(query) ||
               listing.gender.toLowerCase().contains(query) ||
               listing.color.toLowerCase().contains(query) ||
               listing.location.toLowerCase().contains(query);
      }).toList();
    }
    
    // Apply other filters from user selection
    if (_currentFilters != null) {
      final filters = _currentFilters!;
      
      // Filter by pet type
      if (filters['petType'] != 'All') {
        filteredListings = filteredListings.where((listing) => 
          listing.petType.toLowerCase() == filters['petType'].toLowerCase()
        ).toList();
      }
      
      // Filter by breed
      if (filters['breed'] != 'All') {
        filteredListings = filteredListings.where((listing) => 
          listing.breed.toLowerCase() == filters['breed'].toLowerCase()
        ).toList();
      }
      
      // Filter by gender
      if (filters['gender'] != 'All') {
        filteredListings = filteredListings.where((listing) => 
          listing.gender.toLowerCase() == filters['gender'].toLowerCase()
        ).toList();
      }
      
      // Filter by age range
      if (filters['ageRange'] != 'All') {
        filteredListings = filteredListings.where((listing) {
          final age = listing.age;
          switch (filters['ageRange']) {
            case '0-1 years':
              return age >= 0 && age <= 1;
            case '1-3 years':
              return age > 1 && age <= 3;
            case '3-5 years':
              return age > 3 && age <= 5;
            case '5-8 years':
              return age > 5 && age <= 8;
            case '8+ years':
              return age > 8;
            default:
              return true;
          }
        }).toList();
      }
      
      // Filter by price range
      if (filters['priceRange'] != 'All') {
        filteredListings = filteredListings.where((listing) {
          final price = listing.adoptionFee;
          switch (filters['priceRange']) {
            case 'Free':
              return price == 0;
            case '0-5000 DZD':
              return price >= 0 && price <= 5000;
            case '5000-15000 DZD':
              return price > 5000 && price <= 15000;
            case '15000-30000 DZD':
              return price > 15000 && price <= 30000;
              case '30000+ DZD':
              return price > 30000;
            default:
              return true;
          }
        }).toList();
      }
      
      // Filter by location
      if (filters['location'] != 'All') {
        filteredListings = filteredListings.where((listing) {
          final listingLocation = listing.location.toLowerCase();
          final selectedLocation = filters['location'].toLowerCase();
          
          // Check if the listing location contains the selected location
          // This handles cases where location might be "Algiers, Algeria" vs just "Algiers"
          return listingLocation.contains(selectedLocation) || 
                 selectedLocation.contains(listingLocation);
        }).toList();
      }
      
      // Filter by active status
      if (filters['onlyActive'] == true) {
        filteredListings = filteredListings.where((listing) => 
          listing.isActive
        ).toList();
      }
      
      // Filter by photos
      if (filters['onlyWithPhotos'] == true) {
        filteredListings = filteredListings.where((listing) => 
          listing.imageUrls.isNotEmpty
        ).toList();
      }
    }
    
    return filteredListings;
  }

  List<AdoptionListing> _applyFiltersExcludingLocation(List<AdoptionListing> listings) {
    List<AdoptionListing> filteredListings = List.from(listings);
    
    // Apply search query filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredListings = filteredListings.where((listing) {
        return listing.title.toLowerCase().contains(query) ||
               listing.description.toLowerCase().contains(query) ||
               listing.petType.toLowerCase().contains(query) ||
               listing.breed.toLowerCase().contains(query) ||
               listing.gender.toLowerCase().contains(query) ||
               listing.color.toLowerCase().contains(query) ||
               listing.location.toLowerCase().contains(query);
      }).toList();
    }
    
    // Apply user's current location filter (constant filter for "Pets near me")
    if (_userAddress.isNotEmpty && _userAddress != 'Getting your location...' && 
        _userAddress != 'Location permission denied' && 
        _userAddress != 'Location permission permanently denied' &&
        _userAddress != 'Unable to get location') {
      
      // Extract city from user's address
      final userCity = _extractCityFromAddress(_userAddress);
      if (userCity.isNotEmpty) {
        filteredListings = filteredListings.where((listing) {
          final listingLocation = listing.location.toLowerCase();
          return listingLocation.contains(userCity.toLowerCase()) ||
                 userCity.toLowerCase().contains(listingLocation);
        }).toList();
      }
    }
    
    // Apply other filters from user selection
    if (_currentFilters != null) {
      final filters = _currentFilters!;
      
      // Filter by pet type
      if (filters['petType'] != 'All') {
        filteredListings = filteredListings.where((listing) => 
          listing.petType.toLowerCase() == filters['petType'].toLowerCase()
        ).toList();
      }
      
      // Filter by breed
      if (filters['breed'] != 'All') {
        filteredListings = filteredListings.where((listing) => 
          listing.breed.toLowerCase() == filters['breed'].toLowerCase()
        ).toList();
      }
      
      // Filter by gender
      if (filters['gender'] != 'All') {
        filteredListings = filteredListings.where((listing) => 
          listing.gender.toLowerCase() == filters['gender'].toLowerCase()
        ).toList();
      }
      
      // Filter by age range
      if (filters['ageRange'] != 'All') {
        filteredListings = filteredListings.where((listing) {
          final age = listing.age;
          switch (filters['ageRange']) {
            case '0-1 years':
              return age >= 0 && age <= 1;
            case '1-3 years':
              return age > 1 && age <= 3;
            case '3-5 years':
              return age > 3 && age <= 5;
            case '5-8 years':
              return age > 5 && age <= 8;
            case '8+ years':
              return age > 8;
            default:
              return true;
          }
        }).toList();
      }
      
      // Filter by price range
      if (filters['priceRange'] != 'All') {
        filteredListings = filteredListings.where((listing) {
          final price = listing.adoptionFee;
          switch (filters['priceRange']) {
            case 'Free':
              return price == 0;
            case '0-5000 DZD':
              return price >= 0 && price <= 5000;
            case '5000-15000 DZD':
              return price > 5000 && price <= 15000;
            case '15000-30000 DZD':
              return price > 15000 && price <= 30000;
            case '30000+ DZD':
              return price > 30000;
            default:
              return true;
          }
        }).toList();
      }
      
      // Filter by active status
      if (filters['onlyActive'] == true) {
        filteredListings = filteredListings.where((listing) => 
          listing.isActive
        ).toList();
      }
      
      // Filter by photos
      if (filters['onlyWithPhotos'] == true) {
        filteredListings = filteredListings.where((listing) => 
          listing.imageUrls.isNotEmpty
        ).toList();
      }
    }
    
    return filteredListings;
  }

  String _extractCityFromAddress(String address) {
    // Common Algerian cities to look for
    final cities = [
      'Alger', 'Oran', 'Constantine', 'Annaba', 'Batna', 'Setif', 'Blida', 
      'Tlemcen', 'Djelfa', 'Jijel', 'Skikda', 'Sidi Bel Abbès', 'Guelma', 
      'Médéa', 'Mostaganem', 'M\'Sila', 'Mascara', 'Ouargla', 'El Bayadh', 
      'Illizi', 'Bordj Bou Arréridj', 'Boumerdès', 'El Tarf', 'Tindouf', 
      'Tissemsilt', 'El Oued', 'Khenchela', 'Souk Ahras', 'Tipaza', 'Mila', 
      'Aïn Defla', 'Naâma', 'Aïn Témouchent', 'Ghardaïa', 'Relizane'
    ];
    
    final addressLower = address.toLowerCase();
    
    for (final city in cities) {
      if (addressLower.contains(city.toLowerCase())) {
        return city;
      }
    }
    
    // If no city found, try to extract from the address
    final parts = address.split(',');
    if (parts.isNotEmpty) {
      return parts.first.trim();
    }
    
    return '';
  }



  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula to calculate distance between two points
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(_degreesToRadians(lat1)) * math.sin(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan(math.sqrt(a) / math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
} 