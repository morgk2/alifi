import 'package:flutter/material.dart';
import 'dart:ui';
import '../dialogs/report_missing_pet_dialog.dart';
import '../dialogs/add_business_dialog.dart';

class MapPage extends StatefulWidget {
  final Function(bool)? onSearchFocusChange;
  
  const MapPage({
    super.key,
    this.onSearchFocusChange,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;
  bool _isSearchFocused = false;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  // Mock data
  final List<String> _recentSearches = [
    'Veterinary Clinic Downtown',
    'Pet Shop Algiers',
    'Animal Hospital',
  ];

  final List<Map<String, String>> _suggestedVets = [
    {
      'name': 'Dr. Sarah\'s Pet Clinic',
      'rating': '4.8',
      'distance': '1.2km',
      'status': 'Open',
    },
    {
      'name': 'Algiers Veterinary Center',
      'rating': '4.6',
      'distance': '2.5km',
      'status': 'Open',
    },
    {
      'name': 'Pet Care Specialists',
      'rating': '4.9',
      'distance': '3.1km',
      'status': 'Closed',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
    _searchController.addListener(_onSearchTextChange);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  void _onSearchFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
    if (_isSearchFocused) {
      _animationController.forward();
      widget.onSearchFocusChange?.call(false); // Hide nav bar
    } else {
      _animationController.reverse();
      widget.onSearchFocusChange?.call(true); // Show nav bar
    }
  }

  void _onSearchTextChange() {
    setState(() {
      // This will trigger a rebuild to show search results
    });
  }

  void _clearSearch() async {
    _searchController.clear();
    await _animationController.reverse();
    setState(() {
      _isSearchFocused = false;
    });
    _searchFocusNode.unfocus();
    widget.onSearchFocusChange?.call(true); // Show nav bar
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchController.removeListener(_onSearchTextChange);
    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchFocusNode.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu(BuildContext context, Offset buttonPosition) {
    if (_isMenuOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      _overlayEntry = _createOverlayEntry(context, buttonPosition);
      Overlay.of(context).insert(_overlayEntry!);
    }
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  OverlayEntry _createOverlayEntry(
      BuildContext context, Offset buttonPosition) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate menu width and position
    const menuWidth = 180.0; // Reduced from 200
    const rightPadding = 16.0;
    final rightPosition = screenWidth - menuWidth - rightPadding;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Blur effect background
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _toggleMenu(context, buttonPosition),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
            ),
          ),
          // Menu items
          Positioned(
            top: buttonPosition.dy + 60,
            right: rightPadding,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: menuWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Add Lost Pet Option
                    InkWell(
                      onTap: () {
                        _toggleMenu(context, buttonPosition);
                        showDialog(
                          context: context,
                          useRootNavigator: true,
                          barrierColor: Colors.black54,
                          builder: (context) => const ReportMissingPetDialog(),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.pets,
                              color: Colors.red[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Report a missing pet',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    // Add Business Option
                    InkWell(
                      onTap: () {
                        _toggleMenu(context, buttonPosition);
                        showDialog(
                          context: context,
                          useRootNavigator: true,
                          barrierColor: Colors.black54,
                          builder: (context) => const AddBusinessDialog(),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.store_rounded,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Add Your Business',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Search Results',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3, // Mock results
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.location_on),
                title:
                    Text('Result ${index + 1} for "${_searchController.text}"'),
                subtitle: Text('Location details ${index + 1}'),
                onTap: () {
                  // Handle search result selection
                  _searchFocusNode.unfocus();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAndSuggestions() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(_recentSearches[index]),
                onTap: () {
                  _searchController.text = _recentSearches[index];
                },
              );
            },
          ),
          // Suggested Vets
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Suggested Veterinarians',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _suggestedVets.length,
            itemBuilder: (context, index) {
              final vet = _suggestedVets[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.local_hospital, color: Colors.blue),
                ),
                title: Text(vet['name']!),
                subtitle: Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber[700]),
                    Text(' ${vet['rating']} • ${vet['distance']}'),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: vet['status'] == 'Open'
                        ? Colors.green[50]
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    vet['status']!,
                    style: TextStyle(
                      color: vet['status'] == 'Open'
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                onTap: () {
                  // Handle vet selection
                  _searchFocusNode.unfocus();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 80,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Search Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: _isSearchFocused
                        ? MediaQuery.of(context).size.width -
                            32 // Full width minus padding
                        : MediaQuery.of(context).size.width -
                            92, // Width with space for plus button
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                          ),
                          suffixIcon: _isSearchFocused
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: _clearSearch,
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Plus Button with fade animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: !_isSearchFocused
                        ? Row(
                            children: [
                              const SizedBox(width: 12),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      offset: const Offset(0, 4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      final RenderBox renderBox = context
                                          .findRenderObject() as RenderBox;
                                      final position =
                                          renderBox.localToGlobal(Offset.zero);
                                      _toggleMenu(context, position);
                                    },
                                    borderRadius: BorderRadius.circular(24),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
            // Animated Results
            Expanded(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return _isSearchFocused
                      ? Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: SingleChildScrollView(
                              child: _searchController.text.isEmpty
                                  ? _buildRecentAndSuggestions()
                                  : _buildSearchResults(),
                            ),
                          ),
                        )
                      : const Center(
                          child: Text(
                            'Map Page',
                            style: TextStyle(fontSize: 24),
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
