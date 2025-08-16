import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import '../utils/app_fonts.dart';
import '../models/service_ad.dart';
import '../services/service_ad_service.dart';

class PostServiceAdPage extends StatefulWidget {
  final ServiceAdType serviceType;
  final ServiceAd? existingAd;

  const PostServiceAdPage({
    super.key,
    required this.serviceType,
    this.existingAd,
  });

  @override
  State<PostServiceAdPage> createState() => _PostServiceAdPageState();
}

class _PostServiceAdPageState extends State<PostServiceAdPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final MapController _mapController = MapController();
  
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Available days
  Map<String, bool> _selectedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };
  
  // Available times
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  // Pet types
  Map<String, bool> _selectedPetTypes = {
    'Dogs': false,
    'Cats': false,
    'Birds': false,
    'Rabbits': false,
    'Guinea Pigs': false,
    'Hamsters': false,
    'Fish': false,
    'Reptiles': false,
    'Other': false,
  };
  
  // Location
  LatLng _selectedLocation = LatLng(36.7538, 3.0588); // Default to Algiers
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingAd != null) {
      _populateFieldsFromExistingAd();
    }
  }

  void _populateFieldsFromExistingAd() {
    final ad = widget.existingAd!;
    
    // Basic info
    _nameController.text = ad.serviceName;
    _descriptionController.text = ad.description;
    _locationController.text = ad.locationAddress;
    
    // Location
    _selectedLocation = LatLng(ad.latitude, ad.longitude);
    
    // Times
    if (ad.startTime.isNotEmpty) {
      final startParts = ad.startTime.split(':');
      if (startParts.length == 2) {
        _startTime = TimeOfDay(
          hour: int.tryParse(startParts[0]) ?? 9,
          minute: int.tryParse(startParts[1]) ?? 0,
        );
      }
    }
    
    if (ad.endTime.isNotEmpty) {
      final endParts = ad.endTime.split(':');
      if (endParts.length == 2) {
        _endTime = TimeOfDay(
          hour: int.tryParse(endParts[0]) ?? 17,
          minute: int.tryParse(endParts[1]) ?? 0,
        );
      }
    }
    
    // Days
    for (String day in ad.availableDays) {
      if (_selectedDays.containsKey(day)) {
        _selectedDays[day] = true;
      }
    }
    
    // Pet types
    for (String petType in ad.petTypes) {
      if (_selectedPetTypes.containsKey(petType)) {
        _selectedPetTypes[petType] = true;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String get _serviceTitle {
    return widget.serviceType == ServiceAdType.grooming ? 'Grooming' : 'Training';
  }

  Color get _serviceColor {
    return widget.serviceType == ServiceAdType.grooming ? Colors.orange : Colors.blue;
  }

  IconData get _serviceIcon {
    return widget.serviceType == ServiceAdType.grooming 
        ? CupertinoIcons.scissors_alt 
        : CupertinoIcons.person_2_alt;
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.existingAd != null ? 'Edit $_serviceTitle Ad' : 'Post $_serviceTitle Ad',
          style: TextStyle(
            fontFamily: AppFonts.getTitleFontFamily(context),
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/images/back_icon.png',
              width: 24,
              height: 24,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          if (_isLoading)
            Container(
              margin: const EdgeInsets.only(right: 16),
              width: 20,
              height: 20,
              child: CupertinoActivityIndicator(),
            )
          else
            TextButton(
              onPressed: _submitAd,
              child: Text(
                'Post',
                style: TextStyle(
                  color: _serviceColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Header
              _buildServiceHeader(),
              const SizedBox(height: 32),
              
              // Name Field
              _buildNameField(),
              const SizedBox(height: 24),
              
              // Photo Section
              _buildPhotoSection(),
              const SizedBox(height: 24),
              
              // Description Field
              _buildDescriptionField(),
              const SizedBox(height: 24),
              
              // Available Days
              _buildAvailableDaysSection(),
              const SizedBox(height: 24),
              
              // Available Times
              _buildAvailableTimesSection(),
              const SizedBox(height: 24),
              
              // Pet Types
              _buildPetTypesSection(),
              const SizedBox(height: 24),
              
              // Location Section
              _buildLocationSection(),
              const SizedBox(height: 32),
              
              // Submit Button
              _buildSubmitButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _serviceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _serviceIcon,
              size: 32,
              color: _serviceColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Post $_serviceTitle Service Ad',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: context.titleFont,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fill in the details below to post your ${_serviceTitle.toLowerCase()} service advertisement',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: context.localizedFont,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Service Name', CupertinoIcons.textformat),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'e.g., Professional ${_serviceTitle} Services',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _serviceColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a service name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Service Photo', CupertinoIcons.camera),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.camera_fill,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to add a photo',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontFamily: context.localizedFont,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Show your workspace or previous work',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontFamily: context.localizedFont,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Image will be compressed for faster loading',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 10,
                          fontFamily: context.localizedFont,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Description', CupertinoIcons.doc_text),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe your ${_serviceTitle.toLowerCase()} services, experience, and what makes you special...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _serviceColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            if (value.trim().length < 20) {
              return 'Description should be at least 20 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAvailableDaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Available Days', CupertinoIcons.calendar),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: _selectedDays.keys.map((day) {
              return CheckboxListTile(
                title: Text(
                  day,
                  style: TextStyle(
                    fontFamily: context.localizedFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: _selectedDays[day],
                onChanged: (bool? value) {
                  setState(() {
                    _selectedDays[day] = value ?? false;
                  });
                },
                activeColor: _serviceColor,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableTimesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Available Times', CupertinoIcons.clock),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Time',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: context.localizedFont,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectTime(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _startTime?.format(context) ?? 'Select time',
                          style: TextStyle(
                            color: _startTime != null ? Colors.black : Colors.grey[600],
                            fontFamily: context.localizedFont,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Time',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: context.localizedFont,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectTime(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _endTime?.format(context) ?? 'Select time',
                          style: TextStyle(
                            color: _endTime != null ? Colors.black : Colors.grey[600],
                            fontFamily: context.localizedFont,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPetTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pet Types You Work With', CupertinoIcons.paw),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedPetTypes.keys.map((petType) {
              final isSelected = _selectedPetTypes[petType] ?? false;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPetTypes[petType] = !isSelected;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _serviceColor.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? _serviceColor : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          CupertinoIcons.checkmark,
                          size: 16,
                          color: _serviceColor,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        petType,
                        style: TextStyle(
                          color: isSelected ? _serviceColor : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontFamily: context.localizedFont,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Service Location', CupertinoIcons.location),
        const SizedBox(height: 12),
        
        // Location Input
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Enter your service area or address',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _serviceColor, width: 2),
            ),
            suffixIcon: Icon(CupertinoIcons.location_fill, color: _serviceColor),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your service location';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Map Widget
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
                initialCenter: _selectedLocation,
                initialZoom: 13.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedLocation = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.alifi',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 40,
                      height: 40,
                      child: Icon(
                        CupertinoIcons.location_fill,
                        color: _serviceColor,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        Text(
          'Tap on the map to set your exact service location',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontFamily: context.localizedFont,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitAd,
        style: ElevatedButton.styleFrom(
          backgroundColor: _serviceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? CupertinoActivityIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.add_circled,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.existingAd != null ? 'Update Ad' : 'Post $_serviceTitle Ad',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: _serviceColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontFamily: context.titleFont,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: isStartTime 
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
    );
    
    if (time != null) {
      setState(() {
        if (isStartTime) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate selections
    if (_selectedDays.values.every((selected) => !selected)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one available day'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPetTypes.values.every((selected) => !selected)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one pet type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both start and end times'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use the service type directly
      final serviceAdType = widget.serviceType;

      // Get selected days and pet types
      final selectedDays = _selectedDays.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      final selectedPetTypes = _selectedPetTypes.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Show progress for image upload if image is selected
      if (_selectedImage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CupertinoActivityIndicator(color: Colors.white),
                ),
                SizedBox(width: 12),
                Text('Compressing and uploading image...'),
              ],
            ),
            backgroundColor: _serviceColor.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 10), // Longer duration for upload
          ),
        );
      }

      String adId;
      
      if (widget.existingAd != null) {
        // Update existing ad
        final updates = {
          'serviceName': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'availableDays': selectedDays,
          'startTime': _startTime!.format(context),
          'endTime': _endTime!.format(context),
          'petTypes': selectedPetTypes,
          'locationAddress': _locationController.text.trim(),
          'latitude': _selectedLocation.latitude,
          'longitude': _selectedLocation.longitude,
        };

        // Handle image update if a new image was selected
        if (_selectedImage != null) {
          // This would require extending ServiceAdService to handle image updates
          // For now, we'll just update the other fields
        }

        await ServiceAdService.updateServiceAd(widget.existingAd!.id, updates);
        adId = widget.existingAd!.id;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('$_serviceTitle ad updated successfully!'),
                  ),
                ],
              ),
              backgroundColor: _serviceColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        // Create new ad
        adId = await ServiceAdService.createServiceAd(
          serviceType: serviceAdType,
          serviceName: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          imageFile: _selectedImage,
          availableDays: selectedDays,
          startTime: _startTime!.format(context),
          endTime: _endTime!.format(context),
          petTypes: selectedPetTypes,
          locationAddress: _locationController.text.trim(),
          latitude: _selectedLocation.latitude,
          longitude: _selectedLocation.longitude,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('$_serviceTitle ad posted successfully!'),
                  ),
                ],
              ),
              backgroundColor: _serviceColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(adId); // Return the ad ID
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Error posting ad: ${e.toString().replaceAll('Exception: ', '')}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
