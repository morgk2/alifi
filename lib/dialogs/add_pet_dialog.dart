import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../services/database_service.dart';
import '../models/pet.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'base_dialog.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddPetDialog extends StatefulWidget {
  const AddPetDialog({super.key});

  @override
  State<AddPetDialog> createState() => _AddPetDialogState();
}

class _AddPetDialogState extends State<AddPetDialog> {
  final PageController _wizardController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Pet data
  String _petType = 'Dog';
  String _gender = 'Male';
  String? _breed;
  DateTime? _birthday;
  int? _age;
  double? _weight;
  String _weightUnit = 'kg';
  Color _selectedColor = Colors.orange;
  List<XFile> _selectedImages = [];
  String? _name;

  @override
  void dispose() {
    _weightController.dispose();
    _nameController.dispose();
    _wizardController.dispose();
    super.dispose();
  }

  void _convertWeight() {
    if (_weight != null) {
      setState(() {
        if (_weightUnit == 'kg') {
          _weight = double.parse((_weight! * 2.20462).toStringAsFixed(2));
          _weightController.text = _weight.toString();
          _weightUnit = 'lb';
        } else {
          _weight = double.parse((_weight! / 2.20462).toStringAsFixed(2));
          _weightController.text = _weight.toString();
          _weightUnit = 'kg';
        }
      });
    }
  }

  void _nextStep() async {
    if (_currentStep < _totalSteps - 1) {
      _wizardController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      // Save pet
      await _savePet();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _wizardController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickImage() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _savePet() async {
    if (_name == null || _name!.isEmpty || _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields and add at least one photo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      if (authService.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final userId = authService.currentUser!.id;
      final dbService = DatabaseService();

      // Create a new pet
      final pet = Pet(
        id: '', // Will be set by Firestore
        name: _name!,
        species: _petType,
        breed: _breed ?? '',
        color: _selectedColor.value.toRadixString(16),
        age: _age ?? 0,
        gender: _gender,
        imageUrls: [], // Will be populated by createPetWithImages
        ownerId: userId,
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        medicalInfo: {},
        dietaryInfo: {},
        tags: [],
        weight: _weight,
      );

      // Save pet with images
      await dbService.createPetWithImages(pet, _selectedImages, userId);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding pet: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(_totalSteps, (index) {
        final isActive = index <= _currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isActive ? Colors.orange : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTypeSelection() {
    final types = ['Dog', 'Cat', 'Bird', 'Other'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'What type of pet do you have?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: types.map((type) {
            final isSelected = _petType == type;
            return GestureDetector(
              onTap: () {
                setState(() => _petType = type);
                _nextStep();
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pets,
                      size: 48,
                      color: isSelected ? Colors.orange : Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.orange : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    final genders = ['Male', 'Female'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'What is your pet\'s gender?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: genders.map((gender) {
            final isSelected = _gender == gender;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _gender = gender);
                  _nextStep();
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.orange : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        gender == 'Male' ? Icons.male : Icons.female,
                        size: 48,
                        color: isSelected ? Colors.orange : Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gender,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.orange : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotoSelection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Add some photos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        if (_selectedImages.isEmpty)
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add Photos',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      return GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add More',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        Container(
                          width: 200,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: kIsWeb
                                ? Image.network(
                                    _selectedImages[index].path,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(_selectedImages[index].path),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 16,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _selectedImages.isNotEmpty ? _nextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'What\'s your pet\'s name?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _nameController,
          onChanged: (value) => setState(() => _name = value),
          decoration: const InputDecoration(
            labelText: 'Pet Name*',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) => setState(() => _breed = value),
          decoration: const InputDecoration(
            labelText: 'Breed (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _name?.isNotEmpty == true ? _nextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeSelection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'How old is your pet?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _age = int.tryParse(value);
            });
          },
          decoration: const InputDecoration(
            labelText: 'Age in years',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _age != null ? _nextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightSelection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'How much does your pet weigh?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _weight = double.tryParse(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Weight in $_weightUnit',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: _convertWeight,
              child: Text(
                _weightUnit == 'kg' ? 'Switch to lb' : 'Switch to kg',
                style: const TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _weight != null ? _nextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Choose a color for your pet\'s profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        BlockPicker(
          pickerColor: _selectedColor,
          onColorChanged: (color) {
            setState(() => _selectedColor = color);
          },
          availableColors: const [
            Colors.red,
            Colors.pink,
            Colors.purple,
            Colors.deepPurple,
            Colors.indigo,
            Colors.blue,
            Colors.lightBlue,
            Colors.cyan,
            Colors.teal,
            Colors.green,
            Colors.lightGreen,
            Colors.lime,
            Colors.yellow,
            Colors.amber,
            Colors.orange,
            Colors.deepOrange,
            Colors.brown,
            Colors.grey,
            Colors.blueGrey,
            Colors.black,
          ],
          itemBuilder: (color, isCurrentColor, onTap) => Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: isCurrentColor
                  ? Border.all(color: Colors.white, width: 4)
                  : null,
              boxShadow: isCurrentColor
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.8),
                        blurRadius: 8,
                      )
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Finish',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _previousStep,
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.grey,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: Colors.grey,
                  ),
                ],
              ),
              _buildProgressBar(),
              const SizedBox(height: 32),
              SizedBox(
                height: 400,
                child: PageView(
                  controller: _wizardController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildTypeSelection(),
                    _buildGenderSelection(),
                    _buildPhotoSelection(),
                    _buildNameStep(),
                    _buildAgeSelection(),
                    _buildWeightSelection(),
                    _buildColorSelection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 