import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import '../models/adoption_listing.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/geocoding_service.dart';
import 'package:latlong2/latlong.dart' as latlong;

class AddAdoptionListingDialog extends StatefulWidget {
  final AdoptionListing? listing;

  const AddAdoptionListingDialog({super.key, this.listing});

  @override
  State<AddAdoptionListingDialog> createState() => _AddAdoptionListingDialogState();
}

class _AddAdoptionListingDialogState extends State<AddAdoptionListingDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _healthIssuesController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _manualLocationController = TextEditingController();

  late AnimationController _pageController;
  late AnimationController _dropdownController;
  late Animation<double> _pageAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _dropdownAnimation;

  int _currentStep = 0;
  final int _totalSteps = 5;
  bool _isSaving = false;
  String _errorMessage = '';
  String _selectedPetType = 'Dog';
  String _selectedBreed = '';
  String _selectedGender = 'Male';
  String _selectedColor = '0xFF000000';
  int _selectedAge = 1;
  String _selectedAgeUnit = 'Years';
  File? _selectedImage;
  List<String> _uploadedImageUrls = [];
  List<String> _originalImageUrls = []; // Track original images for deletion
  latlong.LatLng? _userLocation;
  String _userAddress = '';
  bool _useManualLocation = false;

  // Pet documentation toggles
  bool _isVaccinated = false;
  bool _isNeutered = false;
  bool _isMicrochipped = false;
  bool _isHouseTrained = false;
  bool _isGoodWithKids = false;
  bool _isGoodWithDogs = false;
  bool _isGoodWithCats = false;

  final List<String> _petTypes = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Fish', 'Other'];
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _ageUnits = ['Years', 'Months'];
  final List<Color> _colors = [
    Colors.black,
    Colors.white,
    Colors.brown,
    Colors.grey,
    Colors.orange,
    Colors.yellow,
    Colors.red,
    Colors.blue,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _dropdownController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeInOut));
    
    _dropdownAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dropdownController, curve: Curves.easeInOut),
    );

    if (widget.listing != null) {
      _loadExistingData();
    }
    
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      setState(() {
        _userAddress = 'Getting location...';
      });

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('Location service enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        setState(() {
          _userAddress = 'Please enable location services';
        });
        return;
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      print('Initial permission status: $permission');
      
      if (permission == LocationPermission.denied) {
        setState(() {
          _userAddress = 'Requesting location permission...';
        });
        
        permission = await Geolocator.requestPermission();
        print('Permission after request: $permission');
        
        if (permission == LocationPermission.denied) {
          setState(() {
            _userAddress = 'Location permission denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _userAddress = 'Location permission permanently denied';
        });
        return;
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        setState(() {
          _userAddress = 'Getting your position...';
        });

        // Try to get last known position first (faster)
        Position? lastKnownPosition;
        try {
          lastKnownPosition = await Geolocator.getLastKnownPosition();
          print('Last known position: ${lastKnownPosition?.latitude}, ${lastKnownPosition?.longitude}');
        } catch (e) {
          print('Error getting last known position: $e');
        }

        Position position;
        if (lastKnownPosition != null) {
          position = lastKnownPosition;
        } else {
          // Get current position with more lenient settings
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 15),
          );
        }
        
        print('Final position: ${position.latitude}, ${position.longitude}');
        
        setState(() {
          _userLocation = latlong.LatLng(position.latitude, position.longitude);
          _userAddress = 'Getting address...';
        });

        // Get address from coordinates using the geocoding service
        try {
          final address = await GeocodingService.getAddressFromCoordinates(
            position.latitude,
            position.longitude,
          );
          
          setState(() {
            _userAddress = address;
          });
        } catch (e) {
          print('Error getting address: $e');
          setState(() {
            _userAddress = 'Location found (address unavailable)';
          });
        }
      } else {
        setState(() {
          _userAddress = 'Location permission not granted';
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      print('Error type: ${e.runtimeType}');
      setState(() {
        _userAddress = 'Error getting location: ${e.toString()}';
      });
    }
  }

  void _loadExistingData() {
    final listing = widget.listing!;
    _titleController.text = listing.title;
    _descriptionController.text = listing.description;
    _contactController.text = listing.contactNumber;
    _healthIssuesController.text = listing.requirements.where((r) => r.toLowerCase().contains('health')).join(', ');
    _requirementsController.text = listing.requirements.where((r) => !r.toLowerCase().contains('health')).join(', ');
    _selectedPetType = listing.petType;
    _selectedBreed = listing.breed;
    _selectedGender = listing.gender;
    _selectedColor = listing.color;
    _selectedAge = listing.age;
    _selectedAgeUnit = listing.age < 1 ? 'Months' : 'Years';
    _uploadedImageUrls = listing.imageUrls;
    _originalImageUrls = List.from(listing.imageUrls); // Track original images for deletion
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dropdownController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _healthIssuesController.dispose();
         _requirementsController.dispose();
     _manualLocationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.forward();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.reverse();
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _removeExistingImage() {
    setState(() {
      _uploadedImageUrls.clear();
    });
  }

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = '';
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final storageService = Provider.of<StorageService>(context, listen: false);
      final databaseService = DatabaseService();

      if (authService.currentUser == null) {
        throw Exception('No user logged in');
      }

      // Handle image upload and deletion
      if (_selectedImage != null) {
        // Upload new image
        final imageUrl = await storageService.uploadPetPhoto(_selectedImage!);
        _uploadedImageUrls = [imageUrl];
        
        // Delete old images if editing
        if (widget.listing != null && _originalImageUrls.isNotEmpty) {
          for (final oldImageUrl in _originalImageUrls) {
            try {
              await storageService.deleteAdoptionListingImage(oldImageUrl);
              print('Successfully deleted old image: $oldImageUrl');
            } catch (e) {
              print('Error deleting old image $oldImageUrl: $e');
              // Continue with other images even if one fails
            }
          }
        }
      } else if (widget.listing != null && _uploadedImageUrls.isEmpty && _originalImageUrls.isNotEmpty) {
        // If editing and no new image selected but original images were removed
        for (final oldImageUrl in _originalImageUrls) {
          try {
            await storageService.deleteAdoptionListingImage(oldImageUrl);
            print('Successfully deleted removed image: $oldImageUrl');
          } catch (e) {
            print('Error deleting removed image $oldImageUrl: $e');
            // Continue with other images even if one fails
          }
        }
      }

      // Build requirements list
      List<String> requirements = [];
      
      // Add documentation toggles
      if (_isVaccinated) requirements.add('Vaccinated');
      if (_isNeutered) requirements.add('Neutered/Spayed');
      if (_isMicrochipped) requirements.add('Microchipped');
      if (_isHouseTrained) requirements.add('House Trained');
      if (_isGoodWithKids) requirements.add('Good with Kids');
      if (_isGoodWithDogs) requirements.add('Good with Dogs');
      if (_isGoodWithCats) requirements.add('Good with Cats');
      
      // Add health issues
      if (_healthIssuesController.text.isNotEmpty) {
        requirements.add('Health Issues: ${_healthIssuesController.text}');
      }
      
      // Add other requirements
      if (_requirementsController.text.isNotEmpty) {
        requirements.addAll(_requirementsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty));
      }

      final listing = AdoptionListing(
        id: widget.listing?.id ?? '',
        petId: '',
        ownerId: authService.currentUser!.id,
        title: _titleController.text,
        description: _descriptionController.text,
        adoptionFee: 0.0, // No fees
        imageUrls: _uploadedImageUrls,
        contactNumber: _contactController.text,
                 location: _useManualLocation ? _manualLocationController.text : _userAddress,
        coordinates: _userLocation ?? latlong.LatLng(0, 0),
        createdAt: widget.listing?.createdAt ?? DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        isActive: true,
        requirements: requirements,
        petType: _selectedPetType,
        breed: _selectedBreed,
        age: _selectedAge,
        gender: _selectedGender,
        color: _selectedColor,
      );

      if (widget.listing != null) {
        await databaseService.updateAdoptionListing(listing);
      } else {
        await databaseService.createAdoptionListing(listing);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(
                      CupertinoIcons.back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.listing != null ? 'Edit Listing' : 'Add Pet for Adoption',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Progress dots
                  Row(
                    children: List.generate(_totalSteps, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index <= _currentStep 
                              ? Colors.orange 
                              : Colors.grey.withOpacity(0.3),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Form(
                key: _formKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _buildCurrentStep(),
                ),
              ),
            ),

            // Error message
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: CupertinoButton(
                        onPressed: _isSaving ? null : _previousStep,
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        child: const Text(
                          'Back',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: CupertinoButton(
                      onPressed: _isSaving ? null : (_currentStep == _totalSteps - 1 ? _saveListing : _nextStep),
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(25),
                      child: _isSaving
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : Text(
                              _currentStep == _totalSteps - 1 ? 'Save Listing' : 'Continue',
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildPetDetailsStep();
      case 2:
        return _buildPhotoStep();
      case 3:
        return _buildDocumentationStep();
      case 4:
        return _buildContactStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us about the pet you want to put up for adoption',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          _buildModernTextField(
            controller: _titleController,
            label: 'Pet Name',
            placeholder: 'Enter the pet\'s name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          _buildModernTextField(
            controller: _descriptionController,
            label: 'Description',
            placeholder: 'Tell us about the pet\'s personality, behavior, and story...',
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPetDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pet Details',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Help potential adopters understand the pet better',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          _buildModernDropdown(
            label: 'Pet Type',
            value: _selectedPetType,
            items: _petTypes,
            onChanged: (value) {
              setState(() {
                _selectedPetType = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          
          _buildModernTextField(
            controller: TextEditingController(text: _selectedBreed),
            label: 'Breed',
            placeholder: 'Enter the breed',
            onChanged: (value) {
              _selectedBreed = value;
            },
          ),
          const SizedBox(height: 20),
          
                     Row(
             children: [
               Expanded(
                 child: _buildModernTextField(
                   controller: TextEditingController(text: _selectedAge.toString()),
                   label: 'Age',
                   placeholder: 'Age',
                   keyboardType: TextInputType.number,
                   onChanged: (value) {
                     _selectedAge = int.tryParse(value) ?? 1;
                   },
                 ),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: _buildModernDropdown(
                   label: 'Unit',
                   value: _selectedAgeUnit,
                   items: _ageUnits,
                   onChanged: (value) {
                     setState(() {
                       _selectedAgeUnit = value!;
                     });
                   },
                 ),
               ),
             ],
           ),
          const SizedBox(height: 20),
          
          _buildModernDropdown(
            label: 'Gender',
            value: _selectedGender,
            items: _genders,
            onChanged: (value) {
              setState(() {
                _selectedGender = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          
          const Text(
            'Color',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colors.map((color) {
              final isSelected = _selectedColor == '0x${color.value.toRadixString(16)}';
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = '0x${color.value.toRadixString(16)}';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.orange : Colors.grey.withOpacity(0.3),
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pet Photo',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A clear photo helps potential adopters connect with the pet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _uploadedImageUrls.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                  _uploadedImageUrls.first,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.photo,
                                    size: 60,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tap to add photo',
                                    style: TextStyle(
                                      color: Colors.grey.withOpacity(0.7),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                    // Remove button for existing images when editing
                    if (widget.listing != null && _uploadedImageUrls.isNotEmpty && _selectedImage == null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _removeExistingImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    // Remove button for newly selected image
                    if (_selectedImage != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _removeSelectedImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
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

  Widget _buildDocumentationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pet Documentation',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Help potential adopters understand the pet\'s background',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          _buildToggleItem('Vaccinated', _isVaccinated, (value) {
            setState(() {
              _isVaccinated = value;
            });
          }),
          _buildToggleItem('Neutered/Spayed', _isNeutered, (value) {
            setState(() {
              _isNeutered = value;
            });
          }),
          _buildToggleItem('Microchipped', _isMicrochipped, (value) {
            setState(() {
              _isMicrochipped = value;
            });
          }),
          _buildToggleItem('House Trained', _isHouseTrained, (value) {
            setState(() {
              _isHouseTrained = value;
            });
          }),
          _buildToggleItem('Good with Kids', _isGoodWithKids, (value) {
            setState(() {
              _isGoodWithKids = value;
            });
          }),
          _buildToggleItem('Good with Dogs', _isGoodWithDogs, (value) {
            setState(() {
              _isGoodWithDogs = value;
            });
          }),
          _buildToggleItem('Good with Cats', _isGoodWithCats, (value) {
            setState(() {
              _isGoodWithCats = value;
            });
          }),
          
          const SizedBox(height: 24),
          
          _buildModernTextField(
            controller: _healthIssuesController,
            label: 'Health Issues (Optional)',
            placeholder: 'Any health conditions or special needs...',
            maxLines: 3,
          ),
          
          const SizedBox(height: 24),
          
          _buildModernTextField(
            controller: _requirementsController,
            label: 'Additional Requirements (Optional)',
            placeholder: 'Any specific requirements for potential adopters...',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildContactStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'How can potential adopters reach you?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          _buildModernTextField(
            controller: _contactController,
            label: 'Contact Number',
            placeholder: 'Your phone number',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a contact number';
              }
              return null;
            },
          ),
          
                     const SizedBox(height: 24),
           
           // Location Section
           const Text(
             'Location',
             style: TextStyle(
               fontSize: 16,
               fontWeight: FontWeight.w600,
               color: Colors.black,
             ),
           ),
           const SizedBox(height: 8),
           
           // Auto-detected location
           if (!_useManualLocation)
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.blue.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.blue.withOpacity(0.3)),
               ),
               child: Row(
                 children: [
                   Icon(
                     CupertinoIcons.location,
                     color: Colors.blue,
                     size: 20,
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text(
                           'Auto-detected Location',
                           style: TextStyle(
                             fontSize: 14,
                             fontWeight: FontWeight.w600,
                             color: Colors.blue,
                           ),
                         ),
                         const SizedBox(height: 4),
                         Text(
                           _userAddress.isNotEmpty ? _userAddress : 'Getting your location...',
                           style: const TextStyle(
                             fontSize: 16,
                             color: Colors.black,
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
             ),
           
           const SizedBox(height: 16),
           
           // Manual location toggle
           Row(
             children: [
               CupertinoSwitch(
                 value: _useManualLocation,
                 onChanged: (value) {
                   setState(() {
                     _useManualLocation = value;
                   });
                 },
                 activeColor: Colors.orange,
               ),
               const SizedBox(width: 12),
               const Text(
                 'Enter location manually',
                 style: TextStyle(
                   fontSize: 16,
                   color: Colors.black,
                 ),
               ),
             ],
           ),
           
           // Manual location input
           if (_useManualLocation) ...[
             const SizedBox(height: 16),
             _buildModernTextField(
               controller: _manualLocationController,
               label: 'Manual Location',
               placeholder: 'Enter your city, state, or address',
               validator: (value) {
                 if (_useManualLocation && (value == null || value.isEmpty)) {
                   return 'Please enter a location';
                 }
                 return null;
               },
             ),
           ],
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.7),
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
              icon: const Icon(
                CupertinoIcons.chevron_down,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleItem(String title, bool value, void Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.orange,
          ),
        ],
      ),
    );
  }


}
