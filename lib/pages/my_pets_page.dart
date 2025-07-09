import 'package:flutter/material.dart';
import '../widgets/placeholder_image.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:blur/blur.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';

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

  // Start with one pet
  List<Map<String, dynamic>> _myPets = [
    {'name': 'Max', 'image': null},
  ];

  void _showAddPetDialog() async {
    File? petImage;
    String? petName;
    String? petBreed;
    DateTime? petBirthday;
    double? petWeight;
    Color selectedColor = Colors.orange;
    final nameController = TextEditingController();
    final breedController = TextEditingController();
    final weightController = TextEditingController();
    String weightUnit = 'kg';
    int? petAge;
    final picker = ImagePicker();

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Stack(
          children: [
            // Blurred background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Dialog content
            Opacity(
              opacity: anim1.value,
              child: Center(
                child: Material(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Photo picker
                              GestureDetector(
                                onTap: () async {
                                  final picked = await picker.pickImage(source: ImageSource.gallery);
                                  if (picked != null) {
                                    setState(() {
                                      petImage = File(picked.path);
                                    });
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 44,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: petImage != null ? FileImage(petImage!) : null,
                                  child: petImage == null
                                      ? const Icon(Icons.add_a_photo, size: 36, color: Colors.grey)
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 18),
                              // Name
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  hintText: 'Pet Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32),
                                    borderSide: BorderSide(color: Colors.grey[400]!, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                ),
                              ),
                              const SizedBox(height: 14),
                              // Breed
                              TextField(
                                controller: breedController,
                                decoration: InputDecoration(
                                  hintText: 'Breed',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32),
                                    borderSide: BorderSide(color: Colors.grey[400]!, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                ),
                              ),
                              const SizedBox(height: 14),
                              // Birthday
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
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
                                                  primary: Colors.orange,
                                                  onPrimary: Colors.white,
                                                  surface: Colors.white,
                                                  onSurface: Colors.black,
                                                ),
                                                dialogBackgroundColor: Colors.white,
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            petBirthday = picked;
                                            petAge = DateTime.now().year - picked.year - ((DateTime.now().month < picked.month || (DateTime.now().month == picked.month && DateTime.now().day < picked.day)) ? 1 : 0);
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(32),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.cake, color: Colors.orange[300]),
                                            const SizedBox(width: 8),
                                            Text(
                                              petBirthday != null
                                                  ? '${petBirthday!.year}/${petBirthday!.month.toString().padLeft(2, '0')}/${petBirthday!.day.toString().padLeft(2, '0')}'
                                                  : 'Birthday',
                                              style: TextStyle(
                                                color: petBirthday != null ? Colors.black : Colors.grey[500],
                                                fontSize: 16,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (petAge != null)
                                              Text('Age: $petAge', style: const TextStyle(color: Colors.black54)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // Weight
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: weightController,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        hintText: 'Weight',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(32),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(32),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(32),
                                          borderSide: BorderSide(color: Colors.grey[400]!, width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          petWeight = double.tryParse(val);
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  DropdownButton<String>(
                                    value: weightUnit,
                                    borderRadius: BorderRadius.circular(32),
                                    items: const [
                                      DropdownMenuItem(value: 'kg', child: Text('kg')),
                                      DropdownMenuItem(value: 'lb', child: Text('lb')),
                                    ],
                                    onChanged: (val) {
                                      setState(() {
                                        if (val != null && val != weightUnit && petWeight != null) {
                                          if (val == 'kg') {
                                            petWeight = double.parse((petWeight! / 2.20462).toStringAsFixed(2));
                                            weightController.text = petWeight!.toString();
                                          } else {
                                            petWeight = double.parse((petWeight! * 2.20462).toStringAsFixed(2));
                                            weightController.text = petWeight!.toString();
                                          }
                                        }
                                        weightUnit = val!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              // Color picker
                              Row(
                                children: [
                                  const Text('Border Color:'),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      Color tempColor = selectedColor;
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
                                                  backgroundColor: Colors.orange,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('Select'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      setState(() {
                                        selectedColor = tempColor;
                                      });
                                    },
                                    child: CircleAvatar(backgroundColor: selectedColor, radius: 16, child: const Icon(Icons.edit, color: Colors.white, size: 16)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Confirm and Cancel buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black87,
                                        side: BorderSide(color: Colors.grey[300]!),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(32),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(32),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      onPressed: () {
                                        petName = nameController.text.trim();
                                        petBreed = breedController.text.trim();
                                        if (petName != null && petName!.isNotEmpty) {
                                          setState(() {
                                            _myPets.add({
                                              'name': petName,
                                              'breed': petBreed,
                                              'birthday': petBirthday,
                                              'age': petAge,
                                              'weight': petWeight,
                                              'weightUnit': weightUnit,
                                              'color': selectedColor,
                                              'image': petImage,
                                            });
                                          });
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: const Text('Confirm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
    final int totalItems = _myPets.length + 1; // +1 for the plus circle
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
            SizedBox(
              height: 280,
              child: Column(
                children: [
                  SizedBox(
                    height: 240,
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
                          itemCount: totalItems,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final isSelected = _currentPetPage == index;
                            final pageOffset = (index - (_pageController.page ?? 0));
                            final scale = 1.0 - (pageOffset.abs() * 0.1);
                            return Transform.scale(
                              scale: scale.clamp(0.9, 1.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: index < _myPets.length
                                                ? (_myPets[index]['color'] ?? const Color(0xFFF59E0B))
                                                : (isSelected ? const Color(0xFFF59E0B) : Colors.transparent),
                                            width: 6,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: index < _myPets.length
                                              ? Container(
                                                  color: Colors.white,
                                                  child: Center(
                                                    child: Text(
                                                      _myPets[index]['name'] ?? '',
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 22,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Material(
                                                  color: Colors.white,
                                                  child: InkWell(
                                                    borderRadius: BorderRadius.circular(999),
                                                    onTap: _showAddPetDialog,
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 48,
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
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
                      totalItems,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentPetPage
                              ? const Color(0xFFF59E0B)
                              : Colors.grey[300],
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
    );
  }
}
