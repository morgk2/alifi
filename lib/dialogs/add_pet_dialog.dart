import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pet.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class AddPetDialog extends StatefulWidget {
  final Pet? pet;
  const AddPetDialog({super.key, this.pet});

  @override
  State<AddPetDialog> createState() => _AddPetDialogState();
}

class _AddPetDialogState extends State<AddPetDialog> with SingleTickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isReverse = false;
  final TextEditingController _weightController = TextEditingController();
  
  // Replace setState variables with ValueNotifier for better performance
  final ValueNotifier<int> _currentStepNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<double> _weightNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _isKgNotifier = ValueNotifier<bool>(true);
  
  int _currentStep = 0;
  
  // Pet Type Selection
  String? _selectedPetType;
  final int _otherPetIndex = 0;
  final List<String> _otherPetTypes = [
    'Bird', 'Rabbit', 'Hamster', 'Fish',
    'Snake', 'Lizard', 'Guinea Pig', 'Ferret',
    'Turtle', 'Parrot', 'Mouse', 'Rat',
    'Hedgehog', 'Chinchilla', 'Gerbil'
  ];
  bool _showOtherPetArrows = false;
  bool _showOtherPetGrid = false;
  int _selectedOtherPetIndex = -1;
  final List<Map<String, String>> _otherPetGrid = [
    {
      'name': 'Hamster',
      'color': 'assets/images/3d_hamster.png',
      'bw': 'assets/images/3d_hamster_bw.png',
    },
    {
      'name': 'Fish',
      'color': 'assets/images/3d_fish.png',
      'bw': 'assets/images/3d_fish_bw.png',
    },
    {
      'name': 'Guinea Pig',
      'color': 'assets/images/3d_guinea_pig.png',
      'bw': 'assets/images/3d_guinea_pig_bw.png',
    },
    {
      'name': 'Duck',
      'color': 'assets/images/3d_duck.png',
      'bw': 'assets/images/3d_duck_bw.png',
    },
    {
      'name': 'Lizard',
      'color': 'assets/images/3d_lizzard.png',
      'bw': 'assets/images/3d_lizzard_bw.png',
    },
    {
      'name': 'Monkey',
      'color': 'assets/images/3d_monkey.png',
      'bw': 'assets/images/3d_monkey_bw.png',
    },
    {
      'name': 'Rabbit',
      'color': 'assets/images/3d_rabbit.png',
      'bw': 'assets/images/3d_rabbit_bw.png',
    },
    {
      'name': 'Bird',
      'color': 'assets/images/bird_3d.png',
      'bw': 'assets/images/3d_bird_bw.png',
    },
  ];

  // Pet Details
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  
  // Birthday Selection
  DateTime? _selectedDate;
  String _petAge = '';
  
  // Weight Selection
  double _weight = 0.0;
  bool _isKg = true;
  
  // Photo Selection
  File? _selectedImage;
  
  // Color Selection
  Color _selectedColor = Colors.blue;
  final List<Color> _presetColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.amber,
  ];

  // Gender Selection
  String _selectedGender = 'Unknown';

  // Error message for top banner
  String? _errorMessage;
  bool _isSaving = false;

  // Update weight methods
  void _updateWeight(String value) {
    final newWeight = double.tryParse(value);
    if (newWeight != null) {
      _weightNotifier.value = newWeight;
    }
  }

  void _toggleWeightUnit() {
    if (_weightNotifier.value > 0) {
      if (_isKgNotifier.value) {
        // Convert kg to lb
        final newWeight = _weightNotifier.value * 2.20462;
        _weightNotifier.value = newWeight;
        _weightController.text = newWeight.toStringAsFixed(1);
      } else {
        // Convert lb to kg
        final newWeight = _weightNotifier.value * 0.453592;
        _weightNotifier.value = newWeight;
        _weightController.text = newWeight.toStringAsFixed(1);
      }
    }
    _isKgNotifier.value = !_isKgNotifier.value;
  }

  Color _parseColor(String colorString) {
    final hexMatch = RegExp(r'0x[a-fA-F0-9]{8}').firstMatch(colorString);
    if (hexMatch != null) {
      return Color(int.parse(hexMatch.group(0)!));
    }
    return Colors.blue;
  }

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
        duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pageAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeInOut),
    );
    _updateSlideAnimation();
    // Start initial animation
    _pageController.forward();
    // Prefill fields if editing
    if (widget.pet != null) {
      _selectedPetType = widget.pet!.species;
      _nameController.text = widget.pet!.name;
      _breedController.text = widget.pet!.breed;
      _selectedGender = widget.pet!.gender;
      _selectedDate = DateTime.now().subtract(Duration(days: widget.pet!.age * 365));
      _weight = widget.pet!.weight ?? 0.0;
      _weightNotifier.value = _weight;
      _isKg = true;
      _isKgNotifier.value = true;
      _weightController.text = _weight > 0 ? _weight.toStringAsFixed(1) : '';
      _selectedColor = _parseColor(widget.pet!.color);
      // _selectedImage: not prefilled (would require loading from URL)
    }
  }

  void _updateSlideAnimation() {
    _slideAnimation = Tween<Offset>(
      begin: Offset(_isReverse ? -1 : 1, 0),
      end: Offset.zero,
    ).animate(_pageAnimation);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    
    // Dispose ValueNotifiers
    _currentStepNotifier.dispose();
    _isSavingNotifier.dispose();
    _errorMessageNotifier.dispose();
    _weightNotifier.dispose();
    _isKgNotifier.dispose();
    
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 6) {
      setState(() {
        _isReverse = false;
        _updateSlideAnimation();
        _currentStep++;
        _currentStepNotifier.value = _currentStep;
      });
      _pageController.forward();
    } else {
      _savePet();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _isReverse = true;
        _updateSlideAnimation();
        _currentStep--;
        _currentStepNotifier.value = _currentStep;
      });
      _pageController.forward(from: 0);
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

  void _calculateAge() {
    if (_selectedDate != null) {
      final now = DateTime.now();
      final difference = now.difference(_selectedDate!);
      final years = (difference.inDays / 365).floor();
      final months = ((difference.inDays % 365) / 30).floor();
      
      setState(() {
        _petAge = years > 0 
          ? '$years years ${months > 0 ? '$months months' : ''}'
          : '$months months';
      });
    }
  }

  Future<void> _savePet() async {
    if (_isSavingNotifier.value) return;
    if (_selectedPetType == null || 
        _nameController.text.isEmpty || 
        _selectedDate == null || 
        _weightNotifier.value == 0 || 
        _selectedImage == null) {
      _errorMessageNotifier.value = 'Please fill in all fields';
      return;
    }

    _isSavingNotifier.value = true;
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.currentUser == null) {
        throw Exception('No user logged in');
      }

      // Calculate age in years
      final now = DateTime.now();
      final age = now.difference(_selectedDate!).inDays ~/ 365;

      final pet = Pet(
        id: '',  // Will be set by Firestore
        name: _nameController.text,
        species: _selectedPetType!,
        breed: _breedController.text,
        color: '0x${_selectedColor.value.toRadixString(16)}',
        age: age,
        gender: _selectedGender,
        imageUrls: [], // Will be updated after upload
        ownerId: authService.currentUser!.id,
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        medicalInfo: {}, // Add medical info in future update
        dietaryInfo: {}, // Add dietary info in future update
        tags: [_selectedPetType!.toLowerCase()],
        weight: _weightNotifier.value,
      );

      final petId = await DatabaseService().createPetWithImages(
        pet,
        [_selectedImage!.path],
        isGuest: authService.isGuestMode,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error adding pet: $e';
        });
      }
    } finally {
      if (mounted) _isSavingNotifier.value = false;
    }
  }

  Widget _buildPetTypeSelection() {
    return FadeTransition(
      opacity: _pageAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: !_showOtherPetGrid
                  ? Column(
                      key: const ValueKey('mainRow'),
                      children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                            AnimatedOpacity(
                              opacity: !_showOtherPetGrid ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 500),
                              child: _buildPetTypeCircle('Cat', 'assets/images/cat_icon.png'),
                            ),
                            AnimatedOpacity(
                              opacity: !_showOtherPetGrid ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 500),
                              child: _buildPetTypeCircle('Dog', 'assets/images/dog_icon.png'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        AnimatedSlide(
                          duration: const Duration(milliseconds: 500),
                          offset: _showOtherPetGrid ? const Offset(0, -1.2) : Offset.zero,
                          child: _buildOtherPetTypeSelector(),
                        ),
                      ],
                    )
                  : Column(
                      key: const ValueKey('otherGrid'),
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          width: 180,
                          height: 60,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Other',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: _showOtherPetGrid ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: AnimatedSlide(
                            duration: const Duration(milliseconds: 500),
                            offset: _showOtherPetGrid ? Offset.zero : const Offset(0, 0.2),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1,
                              ),
                              itemCount: _otherPetGrid.length,
                              itemBuilder: (context, index) {
                                final pet = _otherPetGrid[index];
                                final isSelected = _selectedOtherPetIndex == index;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedOtherPetIndex = index;
                                      _selectedPetType = pet['name'];
                                    });
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          AnimatedOpacity(
                                            duration: const Duration(milliseconds: 400),
                                            opacity: isSelected ? 0.0 : 1.0,
                                            child: Image.asset(
                                              pet['bw']!,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          AnimatedOpacity(
                                            duration: const Duration(milliseconds: 400),
                                            opacity: isSelected ? 1.0 : 0.0,
                                            child: Image.asset(
                                              pet['color']!,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 300),
                                        style: TextStyle(
                                          color: isSelected ? Colors.orange : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        child: Text(pet['name']!),
                                      ),
                                    ],
                                  ),
                                );
                              },
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

  Widget _buildPetTypeCircle(String type, String assetPath) {
    final isSelected = _selectedPetType == type;
            return GestureDetector(
              onTap: () {
        setState(() {
          _selectedPetType = type;
          _showOtherPetArrows = false;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect with fade animation
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: isSelected ? 1.0 : 0.0,
              child: Container(
                  width: 160,
                  height: 160,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.15), // Weaker glow
                        blurRadius: 35, // Smoother blur
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                ),
              ),
              // Stack for both images with crossfade
              Stack(
                alignment: Alignment.center,
                  children: [
                  // Black and white image
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: isSelected ? 0.0 : 1.0,
                    child: Image.asset(
                      type == 'Cat' ? 'assets/images/3d_cat_bw.png' : 'assets/images/3d_dog_bw.png',
                      width: type == 'Cat' ? 156 : 150, // Cat is 4% bigger
                      height: type == 'Cat' ? 156 : 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Colored image
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: isSelected ? 1.0 : 0.0,
                    child: Image.asset(
                      type == 'Cat' ? 'assets/images/3d_cat.png' : 'assets/images/3d_dog.png',
                      width: type == 'Cat' ? 156 : 150, // Cat is 4% bigger
                      height: type == 'Cat' ? 156 : 150,
                      fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
            ],
                  ),
                  const SizedBox(height: 16),
          // Text label with animated color
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
                    style: TextStyle(
              color: isSelected ? Colors.orange : Colors.grey,
                      fontWeight: FontWeight.bold,
              fontSize: 20,
                    ),
            child: Text(type),
                  ),
                ],
              ),
    );
  }

  Widget _buildOtherPetTypeSelector() {
    final isSelected = _selectedPetType != null && _otherPetTypes.contains(_selectedPetType);
                      return GestureDetector(
                onTap: () {
        setState(() {
          _showOtherPetGrid = true;
          _selectedOtherPetIndex = -1;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: _showOtherPetGrid ? 180 : 120,
        height: _showOtherPetGrid ? 60 : 120,
                  decoration: BoxDecoration(
          color: _showOtherPetGrid ? Colors.white : (isSelected ? Colors.orange : Colors.white),
          borderRadius: BorderRadius.circular(_showOtherPetGrid ? 30 : 60),
                    border: Border.all(
            color: _showOtherPetGrid ? Colors.grey : (isSelected ? Colors.orange : Colors.grey),
                      width: 2,
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
              'Other',
              key: ValueKey(_showOtherPetGrid),
                        style: TextStyle(
                color: _showOtherPetGrid ? Colors.grey : (isSelected ? Colors.white : Colors.grey),
                          fontWeight: FontWeight.bold,
                    fontSize: 16,
                        ),
                      ),
                  ),
                ),
      ),
    );
  }

  Widget _buildPetDetailsStep() {
    return FadeTransition(
      opacity: _pageAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
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
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
          controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Pet\'s name',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'What breed is your pet?',
                    style: TextStyle(
                fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _breedController,
                decoration: const InputDecoration(
                  hintText: 'Pet\'s breed',
                  border: InputBorder.none,
            ),
          ),
        ),
      ],
        ),
      ),
    );
  }

  Widget _buildGenderStep() {
    return FadeTransition(
      opacity: _pageAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
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
              children: [
                ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.male, color: _selectedGender == 'Male' ? Colors.white : Colors.blue, size: 22),
                      const SizedBox(width: 8),
                      const Text('Male'),
                    ],
                  ),
                  selected: _selectedGender == 'Male',
                  onSelected: (selected) {
                    setState(() {
                      _selectedGender = 'Male';
                    });
                  },
                  selectedColor: Colors.blue[400],
                  backgroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  labelStyle: TextStyle(
                    color: _selectedGender == 'Male' ? Colors.white : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  side: BorderSide(color: Colors.blue[400]!, width: 2),
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.female, color: _selectedGender == 'Female' ? Colors.white : Colors.pink, size: 22),
                      const SizedBox(width: 8),
                      const Text('Female'),
                    ],
                  ),
                  selected: _selectedGender == 'Female',
                  onSelected: (selected) {
                    setState(() {
                      _selectedGender = 'Female';
                    });
                  },
                  selectedColor: Colors.pink[300],
                  backgroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  labelStyle: TextStyle(
                    color: _selectedGender == 'Female' ? Colors.white : Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                  side: BorderSide(color: Colors.pink[300]!, width: 2),
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Unknown'),
                  selected: _selectedGender == 'Unknown',
                  onSelected: (selected) {
                    setState(() {
                      _selectedGender = 'Unknown';
                    });
                  },
                  selectedColor: Colors.grey[400],
                  backgroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  labelStyle: TextStyle(
                    color: _selectedGender == 'Unknown' ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  side: BorderSide(color: Colors.grey[400]!, width: 2),
                ),
              ],
        ),
      ],
        ),
      ),
    );
  }

  Widget _buildBirthdayStep() {
    return FadeTransition(
      opacity: _pageAnimation,
      child: SlideTransition(
        position: _slideAnimation,
                          child: Column(
      mainAxisSize: MainAxisSize.min,
                            children: [
        const Text(
              'When was your pet born?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
            _buildCustomDatePicker(),
            if (_selectedDate != null) ...[
              const SizedBox(height: 24),
                              Text(
                'Age: $_petAge',
                style: const TextStyle(
                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
      ],
                            ],
                          ),
                        ),
                      );
                    }

  Widget _buildCustomDatePicker() {
    final now = DateTime.now();
    return Container(
      height: 200,
                          decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
      children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDatePickerWheel(
                items: List.generate(31, (i) => (i + 1).toString().padLeft(2, '0')),
                selectedItem: _selectedDate?.day.toString().padLeft(2, '0') ?? '01',
          onChanged: (value) {
                  final newDate = DateTime(
                    _selectedDate?.year ?? now.year,
                    _selectedDate?.month ?? now.month,
                    int.parse(value),
                  );
            setState(() {
                    _selectedDate = newDate;
                    _calculateAge();
            });
          },
              ),
              _buildDatePickerWheel(
                items: List.generate(12, (i) => (i + 1).toString().padLeft(2, '0')),
                selectedItem: _selectedDate?.month.toString().padLeft(2, '0') ?? '01',
                onChanged: (value) {
                  final newDate = DateTime(
                    _selectedDate?.year ?? now.year,
                    int.parse(value),
                    _selectedDate?.day ?? 1,
                  );
                              setState(() {
                    _selectedDate = newDate;
                    _calculateAge();
                              });
                            },
              ),
              _buildDatePickerWheel(
                items: List.generate(
                  30,
                  (i) => (now.year - i).toString(),
                ),
                selectedItem: _selectedDate?.year.toString() ?? now.year.toString(),
          onChanged: (value) {
                  final newDate = DateTime(
                    int.parse(value),
                    _selectedDate?.month ?? now.month,
                    _selectedDate?.day ?? 1,
                  );
            setState(() {
                    _selectedDate = newDate;
                    _calculateAge();
            });
          },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerWheel({
    required List<String> items,
    required String selectedItem,
    required Function(String) onChanged,
  }) {
    return SizedBox(
      width: 80,
      height: 200,
      child: ListWheelScrollView(
        itemExtent: 40,
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        children: items.map((item) {
          return Center(
            child: Text(
              item,
            style: TextStyle(
                fontSize: 20,
                fontWeight: item == selectedItem ? FontWeight.bold : FontWeight.normal,
                color: item == selectedItem ? Colors.orange : Colors.black,
              ),
            ),
          );
        }).toList(),
        onSelectedItemChanged: (index) => onChanged(items[index]),
      ),
    );
  }

  Widget _buildWeightStep() {
    return FadeTransition(
      opacity: _pageAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
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
              mainAxisAlignment: MainAxisAlignment.center,
          children: [
                Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                    onChanged: _updateWeight,
                    decoration: const InputDecoration(
                      hintText: 'Weight',
                      border: InputBorder.none,
                    ),
              ),
            ),
            const SizedBox(width: 16),
                GestureDetector(
                  onTap: _toggleWeightUnit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                      _isKgNotifier.value ? 'kg' : 'lb',
                      style: const TextStyle(
                        color: Colors.white,
              fontWeight: FontWeight.bold,
                      ),
            ),
          ),
        ),
      ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoStep() {
    return FadeTransition(
      opacity: _pageAnimation,
      child: SlideTransition(
        position: _slideAnimation,
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
              'Add a photo of your pet',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? const Icon(
                        Icons.add_photo_alternate,
                        size: 64,
                        color: Colors.grey,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorStep() {
    return FadeTransition(
      opacity: _pageAnimation,
      child: SlideTransition(
        position: _slideAnimation,
                              child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
              'Choose a color for your pet\'s profile',
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
          children: [
                ..._presetColors.map((color) => _buildColorCircle(color)),
                _buildCustomColorCircle(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    final isSelected = _selectedColor.value == color.value;
    return GestureDetector(
      onTap: () {
                  setState(() {
          _selectedColor = color;
                  });
                },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                                                  color: Colors.white,
              )
            : null,
      ),
    );
  }

  Widget _buildCustomColorCircle() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pick a color'),
            content: SingleChildScrollView(
              child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
                            ),
                          );
                        },
      child: Container(
        width: 60,
        height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
          gradient: const SweepGradient(
            colors: [
              Colors.red,
              Colors.yellow,
              Colors.green,
              Colors.blue,
              Colors.purple,
              Colors.red,
            ],
          ),
          boxShadow: [
                          BoxShadow(
              color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.color_lens,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
            children: [
              Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Text(
                'Step ${_currentStep + 1} of 7',
                style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              Text(
                '${((_currentStep + 1) / 7 * 100).round()}%',
                style: const TextStyle(
                  color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
              ),
            ],
                                  ),
                                  const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 7,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width;
    final dialogHeight = screenSize.height;
    final safeAreaPadding = MediaQuery.of(context).padding;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.zero, // Remove default padding
      child: Stack(
        children: [
          SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          children: [
            // Top safe area padding
            SizedBox(height: safeAreaPadding.top),

                // Error banner
                ValueListenableBuilder<String?>(
                  valueListenable: _errorMessageNotifier,
                  builder: (context, errorMessage, child) {
                    if (errorMessage != null && errorMessage.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Material(
                          color: Colors.red[400],
                          borderRadius: BorderRadius.circular(12),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            leading: const Icon(Icons.error_outline, color: Colors.white),
                            title: Text(
                              errorMessage,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => _errorMessageNotifier.value = null,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
            
            // Header with cancel button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.grey,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                  Text(
                    widget.pet != null ? 'Edit existing pet' : 'Add Pet',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  // Empty space for symmetry
                  SizedBox(width: 70),
                ],
              ),
            ),
            
            // Progress bar
            _buildProgressBar(),
            
            // Main content
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! < 0) {
                      // Swipe left to go to next step
                      if (_currentStep < 6) {
                        setState(() {
                          _isReverse = false;
                          _updateSlideAnimation();
                          _currentStep++;
                          _currentStepNotifier.value = _currentStep;
                        });
                        _pageController.forward(from: 0);
                      } else {
                        _savePet();
                      }
                    } else if (details.primaryVelocity! > 0) {
                      // Swipe right to go to previous step
                      if (_currentStep > 0) {
                        setState(() {
                          _isReverse = true;
                          _updateSlideAnimation();
                          _currentStep--;
                          _currentStepNotifier.value = _currentStep;
                        });
                        _pageController.forward(from: 0);
                      }
                    }
                  }
                },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
                  child: [
                    _buildPetTypeSelection(),
                    _buildPetDetailsStep(),
                      _buildGenderStep(),
                    _buildBirthdayStep(),
                    _buildWeightStep(),
                    _buildPhotoStep(),
                    _buildColorStep(),
                  ][_currentStep],
                  ),
                ),
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 24 + safeAreaPadding.bottom, // Add safe area padding at bottom
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (hidden on first step)
                  _currentStep > 0
                      ? TextButton.icon(
                    onPressed: _previousStep,
                    icon: const Icon(Icons.arrow_back),
                          label: const Text('Back'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                          ),
                        )
                      : const SizedBox(width: 100), // Empty space for alignment
                  
                  // Next/Add button
                  ElevatedButton(
                    onPressed: _isSavingNotifier.value ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentStep == 6 ? 'Add Pet' : 'Next',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
            ),
          ],
        ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isSavingNotifier,
            builder: (context, isSaving, child) {
              if (isSaving) {
                return Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
} 