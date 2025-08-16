import 'package:flutter/material.dart';
import 'package:alifi/models/pet.dart';
import 'package:alifi/services/database_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geocoding/geocoding.dart';
import 'location_picker_dialog.dart';
import '../l10n/app_localizations.dart';
import '../services/geocoding_service.dart';

class ReportMissingPetDialog extends StatefulWidget {
  final Pet? pet;
  final String userId;
  const ReportMissingPetDialog({super.key, this.pet, required this.userId});

  @override
  State<ReportMissingPetDialog> createState() => _ReportMissingPetDialogState();
}

class _ReportMissingPetDialogState extends State<ReportMissingPetDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  DateTime _lastSeen = DateTime.now();
  TimeOfDay _lastSeenTime = TimeOfDay.now();
  String? _selectedImage;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = false;
  latlong.LatLng? _currentLocation;
  String? _currentAddress;
  final List<String> _contactNumbers = [];

  // Add pet type state
  String _selectedType = 'dog';
  final List<Map<String, dynamic>> _petTypes = [
    {'type': 'dog', 'asset': 'assets/images/dog_icon.png'},
    {'type': 'cat', 'asset': 'assets/images/cat_icon.png'},
  ];

  // For swipeable steps
  final PageController _pageController = PageController();
  int _currentStep = 0;
  int get _totalSteps => widget.pet == null ? 5 : 4;

  bool get _isValid {
    if (widget.pet != null) {
      return _descriptionController.text.trim().isNotEmpty &&
             _currentLocation != null &&
             _contactNumbers.isNotEmpty;
    }
    return _nameController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty &&
      _currentLocation != null &&
      _contactNumbers.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
    if (widget.pet != null) {
      _descriptionController.text = widget.pet!.description ?? '';
      _nameController.text = widget.pet!.name;
    }
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _rewardController.dispose();
    _locationController.dispose();
    _contactNumberController.dispose();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastSeen,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _lastSeen) {
      setState(() {
        _lastSeen = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _lastSeenTime,
    );
    if (picked != null && picked != _lastSeenTime) {
      setState(() {
        _lastSeenTime = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    // TODO: Implement image picking
    setState(() {
      _selectedImage = 'assets/images/placeholder_pet.jpg';
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      // Get address from coordinates using the geocoding service
      try {
        final address = await GeocodingService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (address.isNotEmpty && address != 'Location found (address unavailable)') {
          _currentAddress = address;
          _locationController.text = address;
        }
      } catch (e) {
        print('Error getting address from coordinates: $e');
      }

      setState(() {
        _currentLocation = latlong.LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() => _isLoading = false);
      _showError('Could not get current location. Please try again.');
    }
  }

  void _addContactNumber() {
    final number = _contactNumberController.text.trim();
    if (number.isNotEmpty) {
      setState(() {
        _contactNumbers.add(number);
        _contactNumberController.clear();
      });
    }
  }

  void _removeContactNumber(String number) {
    setState(() {
      _contactNumbers.remove(number);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _showValidationError() {
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -1.0, end: 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset:
                    Offset(0, MediaQuery.of(context).size.height * value * 0.1),
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Please fill in all required fields (photo, name, and description)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> _showConfirmationDialog() async {
    if (!_isValid) {
      _showValidationError();
      return;
    }

    final bool? confirmed = await showDialog(
      context: context,
      barrierColor: Colors.black54,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          child: Dialog(
            elevation: 24,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.pets,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Are you sure?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This will post your missing pet report to the community.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        // Get the last seen datetime by combining date and time
        final lastSeenDateTime = DateTime(
          _lastSeen.year,
          _lastSeen.month,
          _lastSeen.day,
          _lastSeenTime.hour,
          _lastSeenTime.minute,
        );

        // Parse reward amount
        double reward = 0;
        try {
          reward = double.parse(_rewardController.text.trim());
        } catch (e) {
          print('Invalid reward amount: ${_rewardController.text}');
        }

        // Report the lost pet
        await _databaseService.reportLostPet(
          name: widget.pet?.name ?? _nameController.text.trim(),
          species: widget.pet?.species ?? _selectedType,
          userId: widget.userId,
          location: _currentLocation!,
          address: _currentAddress ?? _locationController.text.trim(),
          description: _descriptionController.text.trim(),
          contactNumbers: _contactNumbers,
          reward: reward,
          lastSeenDate: lastSeenDateTime,
          existingPetId: widget.pet?.id, // Pass existing pet ID if available
        );

      // Close the report dialog with animation
        if (!mounted) return;
      await _animationController.reverse();
      if (!mounted) return;
      Navigator.of(context).pop();

      // Show notification banner
      if (!mounted) return;
      _showNotificationBanner(context);
      } catch (e) {
        print('Error reporting lost pet: $e');
        _showError('Failed to report lost pet. Please try again.');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showNotificationBanner(BuildContext context) {
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -1.0, end: 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset:
                    Offset(0, MediaQuery.of(context).size.height * value * 0.1),
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.sentiment_very_dissatisfied,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Missing Pet Report Submitted',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We hope you find your pet soon! The community will be notified.',
                          style: TextStyle(
                            color: Colors.red[900],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Remove the notification after 3 seconds with fade out animation
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Widget _stepWidgetForIndex(int index) {
    if (widget.pet == null) {
      switch (index) {
        case 0:
                            // Step 1: Pet Type Selector
          return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    child: LayoutBuilder(
                              builder: (context, constraints) {
                                double availableWidth = constraints.maxWidth;
                                        double circleSize = 120;
                                        double iconSize = 64;
                                if (availableWidth < 350) {
                                          circleSize = 96;
                                          iconSize = 48;
                                }
                                bool showCircle = availableWidth >= 250;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Select Pet Type',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.center,
                                    ),
                                            const SizedBox(height: 32),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: _petTypes.map((petType) {
                                        final isSelected = _selectedType == petType['type'];
                                        return GestureDetector(
                                          onTap: () => setState(() => _selectedType = petType['type']),
                                          child: Container(
                                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                            child: showCircle
                                                ? AnimatedContainer(
                                                    duration: const Duration(milliseconds: 200),
                                                    width: circleSize,
                                                    height: circleSize,
                                                    decoration: BoxDecoration(
                                                      color: isSelected ? Colors.red[100] : Colors.grey[200],
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: isSelected ? Colors.red : Colors.grey[400]!,
                                                                width: isSelected ? 4 : 1,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                              padding: const EdgeInsets.all(16.0),
                                                      child: Image.asset(
                                                        petType['asset'],
                                                        width: iconSize,
                                                        height: iconSize,
                                                        color: isSelected ? Colors.red : Colors.grey[700],
                                                        colorBlendMode: BlendMode.srcIn,
                                                      ),
                                                    ),
                                                  )
                                                : Image.asset(
                                                    petType['asset'],
                                                    width: iconSize,
                                                    height: iconSize,
                                                    color: isSelected ? Colors.red : Colors.grey[700],
                                                    colorBlendMode: BlendMode.srcIn,
                                                  ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                );
                              },
                                    ),
          );
        case 1:
          // Step 2: Name and Description
          return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                    const Text(
                      'Pet Name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your pet\'s name (Required)',
                                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                const SizedBox(height: 24),
                    const Text(
                      'Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                                        const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                    maxLines: 6,
                        decoration: const InputDecoration(
                                      hintText: 'Describe your pet - size, color, distinctive features... (Required)',
                                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                              ],
                                    ),
          );
        case 2:
          // Step 3: Last seen and Location
          return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                    const Text(
                      'Last seen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                                        const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${_lastSeen.month}/${_lastSeen.day}/${_lastSeen.year}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                    const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectTime(context),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _lastSeenTime.format(context),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                                        ),
                const SizedBox(height: 24),
                                        const Text(
                                          'Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _pickLocation(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _currentAddress ?? 'Select location on map',
                                          style: TextStyle(
                                            fontSize: 16,
                                  color: _currentAddress != null ? Colors.black : Colors.grey[600],
                                ),
                              ),
                            ),
                            Icon(
                              Icons.map,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                        if (_currentLocation != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Coordinates: ${_currentLocation!.latitude.toStringAsFixed(6)}, ${_currentLocation!.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        case 3:
          // Step 4: Contact Numbers and Reward
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Contact Numbers (Required)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                              width: 1,
                                            ),
                                          ),
                        child: TextField(
                          controller: _contactNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Enter contact number',
                                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                              border: InputBorder.none,
                                            ),
                                          ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _addContactNumber,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Add'),
                                        ),
                                      ],
                                    ),
                const SizedBox(height: 16),
                if (_contactNumbers.isNotEmpty) ...[
                  const Text(
                    'Added Numbers:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _contactNumbers.map((number) {
                      return Chip(
                        label: Text(number),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeContactNumber(number),
                        backgroundColor: Colors.red[100],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                    const Text(
                      'Reward (optional)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                                        const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _rewardController,
                                    keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                                      hintText: 'Enter reward amount in DZD (Optional)',
                                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                                    ),
          );
      }
    } else {
      // widget.pet != null (edit mode)
      switch (index) {
        case 0:
                                  // Step 1: Description
          return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        const Text(
                                          'Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: TextField(
                                            controller: _descriptionController,
                    maxLines: 6,
                                            decoration: const InputDecoration(
                                              hintText: 'Describe your pet - size, color, distinctive features... (Required)',
                                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
          );
        case 1:
                                  // Step 2: Last seen and Location
          return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        const Text(
                                          'Last seen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => _selectDate(context),
                                                child: Container(
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(
                                                      color: Colors.grey[300]!,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '${_lastSeen.month}/${_lastSeen.day}/${_lastSeen.year}',
                                                    style: const TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                            ),
                    const SizedBox(width: 16),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => _selectTime(context),
                                                child: Container(
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(
                                                      color: Colors.grey[300]!,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    _lastSeenTime.format(context),
                                                    style: const TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                const SizedBox(height: 24),
                                        const Text(
                                          'Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 16),
                                        GestureDetector(
                  onTap: () => _pickLocation(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _currentAddress ?? 'Select location on map',
                                          style: TextStyle(
                                            fontSize: 16,
                                  color: _currentAddress != null ? Colors.black : Colors.grey[600],
                                ),
                              ),
                            ),
                            Icon(
                              Icons.map,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                        if (_currentLocation != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Coordinates: ${_currentLocation!.latitude.toStringAsFixed(6)}, ${_currentLocation!.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                                      ],
                                    ),
          );
        case 2:
                                  // Step 3: Contact Numbers
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Contact Numbers (Required)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                              width: 1,
                                            ),
                                          ),
                        child: TextField(
                          controller: _contactNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Enter contact number',
                                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                              border: InputBorder.none,
                                            ),
                                          ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _addContactNumber,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Add'),
                                        ),
                                      ],
                                    ),
                const SizedBox(height: 16),
                if (_contactNumbers.isNotEmpty) ...[
                  const Text(
                    'Added Numbers:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _contactNumbers.map((number) {
                      return Chip(
                        label: Text(number),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeContactNumber(number),
                        backgroundColor: Colors.red[100],
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        case 3:
                                  // Step 4: Reward (optional)
          return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        const Text(
                                          'Reward (optional)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: TextField(
                                            controller: _rewardController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              hintText: 'Enter reward amount in DZD (Optional)',
                                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
          );
      }
    }
    // fallback
    return const SizedBox.shrink();
  }

  Future<void> _pickLocation(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LocationPickerDialog(
        initialLocation: _currentLocation,
      ),
    );

    if (result != null) {
      setState(() {
        _currentLocation = result['location'] as latlong.LatLng;
        _currentAddress = result['address'] as String;
      });
    }
  }

  Future<void> _reportLostPet() async {
    if (!_isValid) {
      _showValidationError();
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Combine date and time
      final lastSeenDateTime = DateTime(
        _lastSeen.year,
        _lastSeen.month,
        _lastSeen.day,
        _lastSeenTime.hour,
        _lastSeenTime.minute,
      );

      // Parse reward amount
      double reward = 0;
      try {
        reward = double.parse(_rewardController.text.trim());
      } catch (e) {
        print('Invalid reward amount: ${_rewardController.text}');
      }

      // Report the lost pet with all required fields
      final lostPetId = await _databaseService.reportLostPet(
        name: widget.pet?.name ?? _nameController.text.trim(),
        species: widget.pet?.species ?? _selectedType,
        userId: widget.userId,
        location: _currentLocation!,
        address: _currentAddress ?? _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        contactNumbers: _contactNumbers,
        reward: reward,
        lastSeenDate: lastSeenDateTime,
        existingPetId: widget.pet?.id, // Pass existing pet ID if available
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet reported as lost successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('Error submitting lost pet report: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error reporting lost pet: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDialogHeight = screenHeight * 0.9;
    final maxDialogWidth = screenWidth * 0.95;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: Dialog(
              insetPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                constraints: BoxConstraints(
                  maxHeight: maxDialogHeight,
                  maxWidth: maxDialogWidth,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              _animationController.reverse().then((_) {
                                Navigator.of(context).pop();
                              });
                            },
                          icon: const Icon(Icons.close),
                            ),
                        const Expanded(
                          child: Text(
                            'Report a missing pet',
                              style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 40), // Balance the close button
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: List.generate(_totalSteps, (index) {
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: index <= _currentStep ? Colors.red : Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _totalSteps,
                        onPageChanged: (index) => setState(() => _currentStep = index),
                        itemBuilder: (context, index) {
                          return RepaintBoundary(
                            child: _stepWidgetForIndex(index),
                          );
                        },
                          ),
                        ),
                    const SizedBox(height: 16),
                    // Navigation buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          if (_currentStep > 0)
                        Expanded(
                          child: TextButton(
                                onPressed: _prevStep,
                            style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Back'),
                              ),
                            ),
                          if (_currentStep > 0)
                            const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _currentStep == _totalSteps - 1 
                                ? _reportLostPet 
                                : _nextStep,
                              style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                              child: Text(
                                _currentStep == _totalSteps - 1 ? 'Report Pet' : 'Next',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ),
                  ],
                  ),
                    ),
                                         const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


}
