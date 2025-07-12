import 'package:flutter/material.dart';
import '../widgets/placeholder_image.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:blur/blur.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({super.key});

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> {
  final PageController _pageController = PageController(
    viewportFraction: 0.92,
  );
  int _currentPetPage = 0;

  // Start with no pets
  List<Map<String, dynamic>> _myPets = [];

  Widget _buildPetImage(Map<String, dynamic> pet) {
    if (kIsWeb && pet['webImage'] != null) {
      return Image.memory(
        pet['webImage'] as Uint8List,
        fit: BoxFit.cover,
      );
    } else if (!kIsWeb && pet['image'] != null) {
      return Image.file(
        pet['image'] as File,
        fit: BoxFit.cover,
      );
    } else {
      return Center(
        child: Text(
          pet['name'] ?? '',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      );
    }
  }

  void _showAddPetDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) => const AddPetWizard(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    ).then((newPet) {
      if (newPet != null) {
        setState(() {
          _myPets.add(newPet as Map<String, dynamic>);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.animateToPage(
                _myPets.length - 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        });
      }
    });
  }

  void _showEditPetDialog(Map<String, dynamic> pet, int index) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) => EditPetWizard(
        pet: pet,
        onSave: (editedPet) {
          setState(() {
            _myPets[index] = editedPet;
          });
        },
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const SizedBox(height: 60),
          GestureDetector(
            onTap: _showAddPetDialog,
                child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF59E0B),
                  width: 6,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 48,
                  color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 24),
          Text(
            'Add your first pet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
    );
  }

  Widget _buildPetList() {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Column(
            children: [
              SizedBox(
                height: 210,
                child: Stack(
                  children: [
                    // Side fades
                    Positioned.fill(
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white,
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // PageView
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _myPets.length + 1, // +1 for add button
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final pageOffset = (index - (_pageController.page ?? 0));
                        final scale = 1.0 - (pageOffset.abs() * 0.1);

                        // Add pet button
                        if (index == _myPets.length) {
                          return Transform.scale(
                            scale: scale.clamp(0.9, 1.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: _showAddPetDialog,
                                    child: Container(
                                      width: 140, // Smaller circle
                                      height: 140, // Smaller circle
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFF59E0B),
                                          width: 6,
                                        ),
                                      ),
              child: Center(
                                        child: Icon(
                                          Icons.add,
                                          size: 40,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Add Pet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final pet = _myPets[index];
                        return Transform.scale(
                          scale: scale.clamp(0.9, 1.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 140, // Smaller circle
                                  height: 140, // Smaller circle
                  child: Container(
                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: pet['color'] ?? const Color(0xFFF59E0B),
                                        width: 6,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Container(
                                        color: Colors.white,
                                        child: _buildPetImage(pet),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  pet['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                if (pet['breed']?.isNotEmpty == true ||
                                    pet['age'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    [
                                      if (pet['breed']?.isNotEmpty == true)
                                        pet['breed'],
                                      if (pet['age'] != null)
                                        pet['age'] < 0
                                            ? '${-pet['age']} ${-pet['age'] == 1 ? 'month' : 'months'}'
                                            : '${pet['age']} ${pet['age'] == 1 ? 'year' : 'years'}',
                                    ].join(' • '),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _myPets.length + 1,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPetPage == index
                          ? const Color(0xFFF59E0B)
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_myPets.isNotEmpty && _currentPetPage < _myPets.length)
          AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double page = _pageController.page ?? 0;
              // Calculate the relative position for the current page
              double pageOffset = page - _currentPetPage;
              
              // Calculate the width of the screen for proper sliding
              double screenWidth = MediaQuery.of(context).size.width;
              
              // Create a sliding effect that matches the PageView
              double slide = pageOffset * screenWidth;
              
              // Add a subtle scale effect
              double scale = 1.0;
              if (pageOffset.abs() <= 1) {
                scale = 1.0 - (pageOffset.abs() * 0.05);
              }
              
              // Add a subtle opacity effect
              double opacity = 1.0;
              if (pageOffset.abs() <= 1) {
                opacity = 1.0 - (pageOffset.abs() * 0.2);
              }

              return Transform.translate(
                offset: Offset(-slide, 0),
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child: child,
                  ),
                ),
              );
            },
            child: _buildPetDetailsPanel(_myPets[_currentPetPage]),
          ),
      ],
    );
  }

  Widget _buildInfoBox(String text, Color backgroundColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: backgroundColor.withOpacity(0.5),
          width: 1,
        ),
      ),
                          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPetDetailsPanel(Map<String, dynamic> pet) {
    final index = _myPets.indexOf(pet);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet name and edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pet['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditPetDialog(pet, index),
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),
            // Breed/Type
            Text(
              pet['breed'] ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            // Info boxes row with proper spacing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        pet['gender'] ?? 'Male',
                        Colors.blue[50]!,
                        Icons.pets,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoBox(
                        pet['age'] < 0
                            ? '${-pet['age']} ${-pet['age'] == 1 ? 'month' : 'months'}'
                            : '${pet['age']} ${pet['age'] == 1 ? 'year' : 'years'}',
                        const Color(0xFFFFF3E0),
                        Icons.pets,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoBox(
                        '${pet['weight'] ?? ''}${pet['weightUnit'] ?? 'kg'}',
                        Colors.green[50]!,
                        Icons.pets,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Health Information Section
            _buildExpandableSection(
              'Health Information',
              Icons.favorite,
              () {
                // TODO: Implement health info expansion
              },
            ),
            const Divider(height: 1),
            // Vet Information Section
            _buildExpandableSection(
              'Vet Information',
              Icons.medical_services,
              () {
                // TODO: Implement vet info expansion
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageScroll);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageScroll() {
    final page = _pageController.page ?? 0;
    if (page != _currentPetPage) {
      setState(() => _currentPetPage = page.round());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPets = _myPets.isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.pets, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'My pets',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search, size: 24),
                  ),
                ],
              ),
            ),
            if (!hasPets)
              _buildEmptyState()
            else
              _buildPetList(),
          ],
        ),
      ),
    );
  }
}

class AddPetWizard extends StatefulWidget {
  const AddPetWizard({super.key});

  @override
  State<AddPetWizard> createState() => _AddPetWizardState();
}

class _AddPetWizardState extends State<AddPetWizard> {
  final PageController _wizardController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7; // Increased for gender step
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Pet data
  String? _petType;
  String? _gender; // Added gender field
  String? _breed;
  DateTime? _birthday;
  int? _age;
  double? _weight;
  String _weightUnit = 'kg';
  Color _selectedColor = Colors.orange;
  File? _petImage;
  Uint8List? _webImage;
  String? _name;

  @override
  void dispose() {
    _weightController.dispose();
    _nameController.dispose();
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

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _wizardController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      // Create pet data
      final newPet = {
        'type': _petType,
        'gender': _gender, // Added gender to pet data
        'breed': _breed,
        'name': _name,
        'birthday': _birthday,
        'age': _age,
        'weight': _weight,
        'weightUnit': _weightUnit,
        'color': _selectedColor,
        'image': _petImage,
        'webImage': _webImage,
      };
      Navigator.of(context).pop(newPet);
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

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFFF59E0B),
            borderRadius: BorderRadius.circular(8),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required String imagePath,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFFF59E0B) : Colors.grey[200],
          border: Border.all(
            color: isSelected ? const Color(0xFFF59E0B) : Colors.grey[300]!,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Image.asset(
                imagePath,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
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
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTypeOption(
              imagePath: 'assets/images/dog_icon.png',
              label: 'Dog',
              isSelected: _petType == 'dog',
              onTap: () => setState(() => _petType = 'dog'),
            ),
            _buildTypeOption(
              imagePath: 'assets/images/cat_icon.png',
              label: 'Cat',
              isSelected: _petType == 'cat',
              onTap: () => setState(() => _petType = 'cat'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          const SizedBox(height: 40),
                              GestureDetector(
                                onTap: () async {
              final picked = await _picker.pickImage(source: ImageSource.gallery);
                                  if (picked != null) {
                if (kIsWeb) {
                  _webImage = await picked.readAsBytes();
                  setState(() {});
                } else {
                  _petImage = File(picked.path);
                  setState(() {});
                }
              }
            },
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
                border: Border.all(
                  color: const Color(0xFFF59E0B),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: _webImage != null
                    ? Image.memory(_webImage!, fit: BoxFit.cover)
                    : _petImage != null
                        ? Image.file(_petImage!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add photo',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'This will help you identify your pet in the app',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                              TextField(
                  controller: _nameController,
                  onChanged: (value) => setState(() => _name = value),
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                                decoration: InputDecoration(
                    hintText: 'Enter pet name',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 18,
                    ),
                                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
                                  ),
                                  filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This is how your pet will be displayed in the app',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          const SizedBox(height: 40),
          GestureDetector(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now().subtract(const Duration(days: 365)),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
                        primary: const Color(0xFFF59E0B),
                                                  onPrimary: Colors.white,
                                                  surface: Colors.white,
                                                  onSurface: Colors.black,
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (picked != null) {
                                          setState(() {
                  _birthday = picked;
                  
                  // Calculate age in years and months
                  final now = DateTime.now();
                  final difference = now.difference(picked);
                  final months = (difference.inDays / 30.44).floor(); // Average days per month
                  
                  if (months < 12) {
                    _age = -months; // Negative value indicates months
                  } else {
                    _age = now.year - picked.year -
                        ((now.month < picked.month ||
                                (now.month == picked.month &&
                                    now.day < picked.day))
                            ? 1
                            : 0);
                  }
                                          });
                                        }
                                      },
                                      child: Container(
              padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
              child: Column(
                                          children: [
                  Icon(Icons.cake, color: Colors.orange[300], size: 48),
                  const SizedBox(height: 16),
                                            Text(
                    _birthday != null
                        ? '${_birthday!.day}/${_birthday!.month}/${_birthday!.year}'
                        : 'Select birthday',
                                              style: TextStyle(
                      fontSize: 18,
                      color: _birthday != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                  if (_age != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _age! < 0 
                          ? '${-_age!} ${-_age! == 1 ? 'month' : 'months'} old'
                          : '$_age ${_age == 1 ? 'year' : 'years'} old',
                      style: TextStyle(
                                                fontSize: 16,
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
  }

  Widget _buildWeightSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (val) {
                          setState(() {
                            _weight = double.tryParse(val);
                          });
                        },
                                      decoration: InputDecoration(
                          hintText: 'Enter weight',
                                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
                                        ),
                                        filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: _convertWeight,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        _weightUnit,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tap the unit to convert between kg and lb',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                                  ),
                                ],
                              ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
                                children: [
        const Text(
          'Choose a color for your pet',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
                                  GestureDetector(
                                    onTap: () async {
            Color tempColor = _selectedColor;
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Pick a color'),
                                            content: SingleChildScrollView(
                                              child: ColorPicker(
                                                pickerColor: tempColor,
                                                onColorChanged: (color) {
                                                  tempColor = color;
                                                },
                                                enableAlpha: false,
                                                showLabel: true,
                                                pickerAreaHeightPercent: 0.8,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text('Cancel'),
                                                onPressed: () => Navigator.of(context).pop(),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('Select'),
                                                onPressed: () {
                        setState(() => _selectedColor = tempColor);
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
          },
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: _selectedColor,
                width: 6,
              ),
            ),
            child: const Center(
              child: Text(
                'Tap to\nchange color',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
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
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
            _buildGenderOption(
              icon: Icons.male,
              label: 'Male',
              color: Colors.blue[100]!,
              isSelected: _gender == 'Male',
              onTap: () => setState(() => _gender = 'Male'),
            ),
            _buildGenderOption(
              icon: Icons.female,
              label: 'Female',
              color: Colors.pink[100]!,
              isSelected: _gender == 'Female',
              onTap: () => setState(() => _gender = 'Female'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required IconData icon,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? color : Colors.grey[200],
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
      ),
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
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _previousStep,
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (_currentStep == 0 && _petType == null) ||
                            (_currentStep == 1 && _gender == null) ||
                            (_currentStep == 4 && (_name?.isEmpty ?? true)) ||
                            (_currentStep == 5 && _age == null) ||
                            (_currentStep == 6 && _weight == null)
                        ? null
                        : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _currentStep == _totalSteps - 1 ? 'Finish' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
  }
}

class EditPetWizard extends StatefulWidget {
  final Map<String, dynamic> pet;
  final Function(Map<String, dynamic>) onSave;

  const EditPetWizard({
    super.key,
    required this.pet,
    required this.onSave,
  });

  @override
  State<EditPetWizard> createState() => _EditPetWizardState();
}

class _EditPetWizardState extends State<EditPetWizard> {
  final PageController _wizardController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Pet data
  String? _petType;
  String? _gender;
  String? _breed;
  DateTime? _birthday;
  int? _age;
  double? _weight;
  String _weightUnit = 'kg';
  Color _selectedColor = Colors.orange;
  File? _petImage;
  Uint8List? _webImage;
  String? _name;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing pet data
    _petType = widget.pet['type'];
    _gender = widget.pet['gender'];
    _breed = widget.pet['breed'];
    _birthday = widget.pet['birthday'];
    _age = widget.pet['age'];
    _weight = widget.pet['weight'];
    _weightUnit = widget.pet['weightUnit'] ?? 'kg';
    _selectedColor = widget.pet['color'] ?? Colors.orange;
    _petImage = widget.pet['image'];
    _webImage = widget.pet['webImage'];
    _name = widget.pet['name'];

    _nameController.text = _name ?? '';
    _weightController.text = _weight?.toString() ?? '';
  }

  @override
  void dispose() {
    _weightController.dispose();
    _nameController.dispose();
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

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _wizardController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      // Save edited pet data
      final editedPet = {
        'type': _petType,
        'gender': _gender,
        'breed': _breed,
        'name': _name,
        'birthday': _birthday,
        'age': _age,
        'weight': _weight,
        'weightUnit': _weightUnit,
        'color': _selectedColor,
        'image': _petImage,
        'webImage': _webImage,
      };
      widget.onSave(editedPet);
      Navigator.of(context).pop();
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

  // Reuse the same UI building methods from AddPetWizard
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
          Row(
                children: [
              Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFFF59E0B),
            borderRadius: BorderRadius.circular(8),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required String imagePath,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFFF59E0B) : Colors.grey[200],
          border: Border.all(
            color: isSelected ? const Color(0xFFF59E0B) : Colors.grey[300]!,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
                    children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Image.asset(
                imagePath,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
                      Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
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
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTypeOption(
              imagePath: 'assets/images/dog_icon.png',
              label: 'Dog',
              isSelected: _petType == 'dog',
              onTap: () => setState(() => _petType = 'dog'),
            ),
            _buildTypeOption(
              imagePath: 'assets/images/cat_icon.png',
              label: 'Cat',
              isSelected: _petType == 'cat',
              onTap: () => setState(() => _petType = 'cat'),
                      ),
                    ],
                  ),
      ],
    );
  }

  Widget _buildPhotoSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () async {
              final picked = await _picker.pickImage(source: ImageSource.gallery);
              if (picked != null) {
                if (kIsWeb) {
                  _webImage = await picked.readAsBytes();
                  setState(() {});
                } else {
                  _petImage = File(picked.path);
                  setState(() {});
                }
              }
            },
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
                border: Border.all(
                  color: const Color(0xFFF59E0B),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: _webImage != null
                    ? Image.memory(_webImage!, fit: BoxFit.cover)
                    : _petImage != null
                        ? Image.file(_petImage!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add photo',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                  ),
                ],
              ),
            ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'This will help you identify your pet in the app',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
                      children: [
                TextField(
                  controller: _nameController,
                  onChanged: (value) => setState(() => _name = value),
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter pet name',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This is how your pet will be displayed in the app',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365)),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: const Color(0xFFF59E0B),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _birthday = picked;
                  
                  // Calculate age in years and months
                  final now = DateTime.now();
                  final difference = now.difference(picked);
                  final months = (difference.inDays / 30.44).floor(); // Average days per month
                  
                  if (months < 12) {
                    _age = -months; // Negative value indicates months
                  } else {
                    _age = now.year - picked.year -
                        ((now.month < picked.month ||
                                (now.month == picked.month &&
                                    now.day < picked.day))
                            ? 1
                            : 0);
                  }
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.cake, color: Colors.orange[300], size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _birthday != null
                        ? '${_birthday!.day}/${_birthday!.month}/${_birthday!.year}'
                        : 'Select birthday',
                    style: TextStyle(
                      fontSize: 18,
                      color: _birthday != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                  if (_age != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _age! < 0 
                          ? '${-_age!} ${-_age! == 1 ? 'month' : 'months'} old'
                          : '$_age ${_age == 1 ? 'year' : 'years'} old',
                      style: TextStyle(
                        fontSize: 16,
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
  }

  Widget _buildWeightInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          const SizedBox(height: 40),
                              Container(
            padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (val) {
                          setState(() {
                            _weight = double.tryParse(val);
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter weight',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: _convertWeight,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        _weightUnit,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tap the unit to convert between kg and lb',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
        ],
      ),
    );
  }

  Widget _buildColorSelection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
                                  children: [
        const Text(
          'Choose a color for your pet',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        GestureDetector(
          onTap: () async {
            Color tempColor = _selectedColor;
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Pick a color'),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: tempColor,
                      onColorChanged: (color) {
                        tempColor = color;
                      },
                      enableAlpha: false,
                      showLabel: true,
                      pickerAreaHeightPercent: 0.8,
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Select'),
                      onPressed: () {
                        setState(() => _selectedColor = tempColor);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
                                      child: Container(
            width: 120,
            height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
              color: Colors.white,
                                          border: Border.all(
                color: _selectedColor,
                                            width: 6,
                                          ),
                                        ),
            child: const Center(
                                                    child: Text(
                'Tap to\nchange color',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
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
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildGenderOption(
              icon: Icons.male,
              label: 'Male',
              color: Colors.blue[100]!,
              isSelected: _gender == 'Male',
              onTap: () => setState(() => _gender = 'Male'),
            ),
            _buildGenderOption(
              icon: Icons.female,
              label: 'Female',
              color: Colors.pink[100]!,
              isSelected: _gender == 'Female',
              onTap: () => setState(() => _gender = 'Female'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required IconData icon,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? color : Colors.grey[200],
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                    _buildNameInput(),
                    _buildAgeSelection(),
                    _buildWeightInput(),
                    _buildColorSelection(),
                      ],
                    ),
                  ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _previousStep,
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: (_currentStep == 0 && _petType == null) ||
                            (_currentStep == 1 && _gender == null) ||
                            (_currentStep == 4 && (_name?.isEmpty ?? true)) ||
                            (_currentStep == 5 && _age == null) ||
                            (_currentStep == 6 && _weight == null)
                        ? null
                        : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _currentStep == _totalSteps - 1 ? 'Save' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
  }
}