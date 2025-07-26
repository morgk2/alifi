import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/pet.dart';
import '../dialogs/add_pet_dialog.dart';
import '../widgets/spinning_loader.dart';
import 'dart:ui';
import '../dialogs/report_missing_pet_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../pages/adoption_center_page.dart';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
// Only import sensors_plus if not web
// ignore: uri_does_not_exist
import 'package:sensors_plus/sensors_plus.dart' if (dart.library.html) '../noop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'pet_health_page.dart';

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({super.key});

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> with SingleTickerProviderStateMixin {
  // Helper to parse color string to Color
  Color _parseColor(String colorString) {
    final hexMatch = RegExp(r'0x[a-fA-F0-9]{8}').firstMatch(colorString);
    if (hexMatch != null) {
      return Color(int.parse(hexMatch.group(0)!));
    }
    return const Color(0xFFF59E0B);
  }
  final PageController _pageController = PageController(
    viewportFraction: 0.92,
  );
  
  // Replace setState variables with ValueNotifier for better performance
  final ValueNotifier<int> _currentPetPageNotifier = ValueNotifier<int>(0);
  final ValueNotifier<List<Pet>> _petsNotifier = ValueNotifier<List<Pet>>([]);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(true);
  
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageScroll);
    _loadPets();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = CurvedAnimation(
      parent: _animationController,
            curve: Curves.easeOutCubic,
    );

    _animationController.forward();
  }

  void _loadPets() async {
    final authService = context.read<AuthService>();
    if (authService.currentUser == null) return;

    final dbService = DatabaseService();
    dbService.getUserPets(authService.currentUser!.id).listen((pets) {
      if (mounted) {
          // Check if this is a new pet being added
        final isNewPet = pets.length > _petsNotifier.value.length;
        _petsNotifier.value = pets;
        _isLoadingNotifier.value = false;
          
          // If a new pet was added, animate to it
          if (isNewPet && _pageController.hasClients) {
            // Animate to the new pet (which will be at the start since we order by createdAt desc)
              _pageController.animateToPage(
              0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
      }
    });
  }

  Widget _buildPetImage(Pet pet) {
    if (pet.imageUrls.isEmpty) {
      return Center(
        child: Text(
          pet.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      );
    }
    
    return CachedNetworkImage(
      imageUrl: pet.imageUrls.first,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(
        child: Text(
          pet.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Center(
          child: Text(
            pet.name,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
      ),
      fadeInDuration: const Duration(milliseconds: 300),
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

  Widget _buildInfoBoxWithImage({
    required String imageAsset,
    required List<String> lines,
    Color? backgroundColor,
  }) {
    return Container(
      width: 90,
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Large faded background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Centered info text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: lines
                  .map((line) => Text(
                        line,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetDetailsPanel(Pet pet) {
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
                  pet.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    // Open AddPetDialog in edit mode, passing the pet info
                    await showDialog(
                      context: context,
                      builder: (context) => AddPetDialog(
                        pet: pet, // Pass the pet to edit
                      ),
                    );
                  },
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),
            // Breed/Type
            if (pet.breed.isNotEmpty)
            Text(
                pet.breed,
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
                      child: _buildInfoBoxWithImage(
                        imageAsset: (pet.gender.toLowerCase() == 'male')
                            ? 'assets/images/gender_male.png'
                            : (pet.gender.toLowerCase() == 'female')
                                ? 'assets/images/gender_female.png'
                                : 'assets/images/gender_male.png', // fallback
                        lines: [
                          pet.gender.isNotEmpty ? pet.gender : 'Unknown',
                        ],
                        backgroundColor: (pet.gender.toLowerCase() == 'female')
                            ? const Color.fromARGB(240, 255, 186, 209) // almost fully saturated pink
                            : const Color.fromARGB(240, 185, 223, 255), // almost fully saturated blue
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoBoxWithImage(
                        imageAsset: 'assets/images/age.png',
                        lines: (() {
                          if (pet.age != null) {
                            if (pet.age < 0) {
                              return [
                                (-pet.age).toString(),
                                (-pet.age == 1 ? 'month' : 'months'),
                              ];
                            } else {
                              return [
                                pet.age.toString(),
                                (pet.age == 1 ? 'year' : 'years'),
                              ];
                            }
                          }
                          return ['Unknown'];
                        })(),
                        backgroundColor: const Color(0xFFFFE0B2), // deeper pastel for age
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoBoxWithImage(
                        imageAsset: 'assets/images/weight.png',
                        lines: (() {
                          if (pet.weight != null) {
                            final weightStr = pet.weight!.toStringAsFixed(1);
                            return [weightStr, 'kg'];
                          }
                          return ['Unknown'];
                        })(),
                        backgroundColor: const Color(0xFFC8E6C9), // deeper pastel for weight
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PetHealthPage(pet: pet),
                  ),
                );
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
            const Divider(height: 1),
            // Pet ID Section
            _buildExpandableSection(
              'Pet ID',
              Icons.badge,
              () async {
                try {
                  // Check if pet has a petId document
                  final petIdQuery = await FirebaseFirestore.instance
                      .collection('petId')
                      .where('petId', isEqualTo: pet.name)
                      .where('userId', isEqualTo: context.read<AuthService>().currentUser?.id)
                      .get();

                  if (petIdQuery.docs.isNotEmpty) {
                    final petIdDoc = petIdQuery.docs.first;
                    final isAvailable = petIdDoc.data()['isAvailable'] ?? false;
                    final idUrl = petIdDoc.data()['idUrl'] ?? '';

                    if (isAvailable && idUrl.isNotEmpty) {
                      // Pet ID is ready - show the ID image
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PetIdDisplayPage(
                            petName: pet.name,
                            idUrl: idUrl,
                          ),
                        ),
                      );
                    } else {
                      // Pet ID is being processed
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PetIdProcessingPage(
                            petName: pet.name,
                          ),
                        ),
                      );
                    }
                  } else {
                    // No petId document exists - show initial request page
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PetIdRequestPage(
                          petNames: _petsNotifier.value.map((p) => p.name).toList(),
                          onPetSelected: (petName) {
                            // Handle pet selection if needed
                          },
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error checking pet ID status: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildPetList() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingNotifier,
      builder: (context, isLoading, child) {
        if (isLoading) {
      return const Center(child: SpinningLoader(color: Colors.orange));
    }

        return ValueListenableBuilder<List<Pet>>(
          valueListenable: _petsNotifier,
          builder: (context, pets, child) {
            if (pets.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
          children: [
            SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
                    itemCount: pets.length + 1, // +1 for add button
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final pageOffset = (index - (_pageController.page ?? 0));
              final scale = 1.0 - (pageOffset.abs() * 0.1);

              // Add pet button
                      if (index == pets.length) {
                return Transform.scale(
                  scale: scale.clamp(0.9, 1.0),
                            child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
                              GestureDetector(
                          onTap: _showAddPetDialog,
            child: Container(
                            width: 140,
                            height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                                color: Colors.grey[300]!,
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
                        const SizedBox(height: 16),
          Text(
                          'Add new pet',
            style: TextStyle(
                            fontSize: 16,
              color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
      ),
    );
  }

                      final pet = pets[index];
              return Transform.scale(
                scale: scale.clamp(0.9, 1.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
                                children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                                      child: Container(
                                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _parseColor(pet.color),
                              width: 6,
                            ),
                          ),
                          child: ClipOval(
                            child: Container(
              color: Colors.white, // Always white inside
                              child: _buildPetImage(pet),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                    ),
                  ],
                ),
                ),
              );
            },
          ),
        ),
                ValueListenableBuilder<int>(
                  valueListenable: _currentPetPageNotifier,
                  builder: (context, currentPage, child) {
                    if (pets.isNotEmpty && currentPage < pets.length) {
                      return Expanded(
            child: AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                if (_pageController.position.haveDimensions) {
                  final page = _pageController.page ?? 0;
                              final pageOffset = (page - currentPage);
                  final slide = pageOffset * 200.0; // Adjust this value to control slide distance
                  final opacity = 1.0 - (pageOffset.abs() * 0.5).clamp(0.0, 1.0);
                  final scale = 1.0 - (pageOffset.abs() * 0.1).clamp(0.0, 0.1);

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
                }
                return child!;
              },
      child: SingleChildScrollView(
                            child: _buildPetDetailsPanel(pets[currentPage]),
                ),
              ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
            ),
          ],
            );
          },
        );
      },
    );
  }

  void _showEditPetDialog(Pet pet) {
    // TODO: Implement edit pet dialog
  }

  void _showEditPetsDialog() async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: StatefulBuilder(
                builder: (context, setDialogState) {
                  return Container(
                    color: Colors.white.withOpacity(0.95),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Edit Pets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 350,
                          height: 400,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _petsNotifier.value.length,
                            itemBuilder: (context, index) {
                              final pet = _petsNotifier.value[index];
                              return FutureBuilder<bool>(
                                future: DatabaseService().isPetLost(pet.id),
                                builder: (context, snapshot) {
                                  final isLost = snapshot.data ?? false;
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 24,
                                      child: Icon(Icons.pets, color: _parseColor(pet.color)),
                                    ),
                                    title: Row(
                                      children: [
                                        Text(pet.name),
                                        if (isLost) ...[
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () async {
                                              // Find the lost_pets doc for this pet
                                              final lostPetQuery = await FirebaseFirestore.instance
                                                .collection('lost_pets')
                                                .where('petId', isEqualTo: pet.id)
                                                .where('isFound', isEqualTo: false)
                                                .limit(1)
                                                .get();
                                              if (lostPetQuery.docs.isEmpty) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('No lost pet report found for this pet.')),
                                                  );
                                                }
                                                return;
                                              }
                                              final lostPetId = lostPetQuery.docs.first.id;
                                              final confirmed = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Mark as Found?'),
                                                  content: const Text('Are you sure you want to mark this pet as found?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, false),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, true),
                                                      child: const Text('Confirm'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirmed == true) {
                                                try {
                                                  await DatabaseService().markLostPetAsFound(lostPetId);
                                                  setDialogState(() {});
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Pet marked as found!')),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Failed to mark as found: $e')),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(left: 4),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: const [
                                                  Icon(Icons.warning_rounded, color: Colors.white, size: 14),
                                                  SizedBox(width: 2),
                                                  Text('LOST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    subtitle: Text(pet.breed),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.orange),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await showDialog(
                                              context: context,
                                              builder: (context) => AddPetDialog(pet: pet),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              barrierColor: Colors.black.withOpacity(0.2),
                                              builder: (context) => Dialog(
                                                backgroundColor: Colors.transparent,
                                                insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(28),
                                                  child: BackdropFilter(
                                                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                                    child: Container(
                                                      color: Colors.white.withOpacity(0.95),
                                                      padding: const EdgeInsets.all(24),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
                                                          const SizedBox(height: 16),
                                                          const Text('Delete Pet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                                                          const SizedBox(height: 8),
                                                          Text('Are you sure you want to delete ${pet.name}?', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                                                          const SizedBox(height: 24),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              TextButton(
                                                                style: TextButton.styleFrom(
                                                                  backgroundColor: Colors.orange,
                                                                  foregroundColor: Colors.white,
                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                                ),
                                                                onPressed: () => Navigator.of(context).pop(false),
                                                                child: const Text('Cancel'),
                                                              ),
                                                              TextButton(
                                                                style: TextButton.styleFrom(
                                                                  backgroundColor: Colors.red,
                                                                  foregroundColor: Colors.white,
                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                                ),
                                                                onPressed: () => Navigator.of(context).pop(true),
                                                                child: const Text('Delete'),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                            if (confirm == true) {
                                              await DatabaseService().deletePet(pet.id);
                                              setDialogState(() {
                                                _petsNotifier.value.removeAt(index);
                                              });
                                              setState(() {}); // Also update main page
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReportMissingPetDialog() async {
    final authService = context.read<AuthService>();
    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to report a missing pet'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_petsNotifier.value.isEmpty) {
      await showDialog(
        context: context,
        builder: (context) => ReportMissingPetDialog(
          userId: authService.currentUser!.id,
        ),
      );
    } else {
      await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.2),
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  color: Colors.white.withOpacity(0.95),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Select a pet to report missing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 350,
                        height: 300,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _petsNotifier.value.length,
                          itemBuilder: (context, index) {
                            final pet = _petsNotifier.value[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 24,
                                child: Icon(Icons.pets, color: _parseColor(pet.color)),
                              ),
                              title: Text(pet.name),
                              subtitle: Text(pet.breed),
                              trailing: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await showDialog(
                                    context: context,
                                    builder: (context) => ReportMissingPetDialog(
                                      pet: pet,
                                      userId: authService.currentUser!.id,
                                    ),
                                  );
                                },
                                child: const Text('Report'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
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

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _animationController.dispose();
    
    // Dispose ValueNotifiers
    _currentPetPageNotifier.dispose();
    _petsNotifier.dispose();
    _isLoadingNotifier.dispose();
    
    super.dispose();
  }

  void _onPageScroll() {
    final page = _pageController.page ?? 0;
    if (page != _currentPetPageNotifier.value) {
      _currentPetPageNotifier.value = page.round();
      // Reset animation for new page
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _showAddPetDialog() {
    showDialog(
                context: context,
      builder: (context) => const AddPetDialog(),
    ).then((added) {
      if (added == true) {
        // Reset animation for the new pet's details panel
        _animationController.reset();
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          fontFamily: 'Montserrat',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                 Row(
                   children: [
                     IconButton(
                       onPressed: () {},
                       icon: const Icon(Icons.search, size: 24),
                     ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 1.0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                )),
                                child: const AdoptionCenterPage(),
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      icon: Image.asset(
                        'assets/images/adoption.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                     PopupMenuButton<String>(
                       icon: const Icon(Icons.more_vert),
                       color: Colors.white,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                       itemBuilder: (context) => [
                         const PopupMenuItem(
                           value: 'edit_pets',
                           child: Text('Edit Pets'),
                         ),
                         const PopupMenuItem(
                           value: 'report_missing',
                           child: Text('Report a missing pet'),
                         ),
                       ],
                       onSelected: (value) {
                         if (value == 'edit_pets') _showEditPetsDialog();
                         if (value == 'report_missing') _showReportMissingPetDialog();
                       },
                     ),
                   ],
                 ),
                ],
              ),
            ),
            Expanded(child: _buildPetList()),
          ],
        ),
      ),
    );
  }
}

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String hint;

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint = '',
  }) : super(key: key);

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _toggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade300, width: 2),
              boxShadow: _expanded
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.value ?? widget.hint,
                  style: TextStyle(
                    color: widget.value == null ? Colors.grey : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(Icons.expand_more, color: Colors.grey, size: 28),
                ),
              ],
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizeTransition(
            sizeFactor: _expandAnim,
            axisAlignment: -1.0,
            child: Container(
              color: Colors.white,
              child: Column(
                children: widget.items.map((item) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        widget.onChanged(item);
                        _toggle();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PetIdRequestPage extends StatefulWidget {
  final List<String> petNames;
  final String? selectedPet;
  final ValueChanged<String?>? onPetSelected;

  const PetIdRequestPage({
    Key? key,
    this.petNames = const [],
    this.selectedPet,
    this.onPetSelected,
  }) : super(key: key);

  @override
  State<PetIdRequestPage> createState() => _PetIdRequestPageState();
}

class _PetIdRequestPageState extends State<PetIdRequestPage> {
  String? dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.selectedPet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/pet_id_cat.png',
                  width: 260,
                  height: 260,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select the pet you want to request the pet ID for',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF3A1A0B),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomDropdown(
                  items: widget.petNames,
                  value: dropdownValue,
                  hint: 'Select pet',
                  onChanged: (value) {
                    setState(() {
                      dropdownValue = value;
                    });
                    if (widget.onPetSelected != null) widget.onPetSelected!(value);
                  },
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierColor: Colors.black.withOpacity(0.9),
                      builder: (context) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: EdgeInsets.zero,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.transparent,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {}, // Prevent closing when tapping the image
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                      child: Container(
                                        color: Colors.white.withOpacity(0.05),
                                        padding: const EdgeInsets.all(24),
                                        child: Image.asset(
                                          'assets/images/card_example.PNG',
                                          fit: BoxFit.contain,
                                          width: 480,
                                          height: 320,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFFA800), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  child: const Text(
                    'View an example',
                    style: TextStyle(
                      color: Color(0xFFFFA800),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (dropdownValue == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a pet first'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      // Get the selected pet's data
                      // For now, we'll use the current user's ID and create a basic document
                      // In a real implementation, you'd need to pass the full pet data to this page
                      final authService = context.read<AuthService>();
                      final currentUserId = authService.currentUser?.id;
                      
                      if (currentUserId == null) {
                        throw Exception('User not authenticated');
                      }

                      // Create the petId document
                      final petIdData = {
                        'userId': currentUserId,
                        'isAvailable': false,
                        'petId': dropdownValue, // Using pet name as identifier for now
                        'idUrl': '',
                        'createdAt': FieldValue.serverTimestamp(),
                        'updatedAt': FieldValue.serverTimestamp(),
                      };

                      // Add to petId collection
                      await FirebaseFirestore.instance.collection('petId').add(petIdData);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pet ID request submitted successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Close the dialog
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error submitting request: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  child: const Text(
                    'Request a pet ID',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Physical Pet ID Request Dialog
class PhysicalIdRequestDialog extends StatefulWidget {
  final String petName;

  const PhysicalIdRequestDialog({
    Key? key,
    required this.petName,
  }) : super(key: key);

  @override
  State<PhysicalIdRequestDialog> createState() => _PhysicalIdRequestDialogState();
}

class _PhysicalIdRequestDialogState extends State<PhysicalIdRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _zipCodeController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Request Physical Pet ID',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF3A1A0B),
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      contentPadding: const EdgeInsets.all(24),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 400,
          maxWidth: 600,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Physical Pet ID for ${widget.petName}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3A1A0B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFA800), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        color: Color(0xFFFFA800),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Price: \$20.00',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A1A0B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Shipping Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A1A0B),
                  ),
                ),
                const SizedBox(height: 12),
                _buildCustomTextField(
                  controller: _fullNameController,
                  label: 'Full Name *',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildCustomTextField(
                  controller: _phoneNumberController,
                  label: 'Phone Number *',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildCustomTextField(
                  controller: _addressController,
                  label: 'Address *',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildCustomTextField(
                  controller: _zipCodeController,
                  label: 'Zip Code *',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your zip code';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'fullName': _fullNameController.text.trim(),
                'phoneNumber': _phoneNumberController.text.trim(),
                'address': _addressController.text.trim(),
                'zipCode': _zipCodeController.text.trim(),
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFA800),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Submit Request'),
        ),
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3A1A0B),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            color: Colors.grey.shade50,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF3A1A0B),
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

// Pet ID Display Page - shows the actual pet ID when ready
class PetIdDisplayPage extends StatelessWidget {
  final String petName;
  final String idUrl;

  const PetIdDisplayPage({
    Key? key,
    required this.petName,
    required this.idUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3A1A0B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Display the actual pet ID image as the main content
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierColor: Colors.black.withOpacity(0.9),
                  builder: (context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.zero,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.transparent,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {}, // Prevent closing when tapping the image
                              child: InteractiveViewer(
                                child: Image.network(
                                  idUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Text(
                                          'Error loading pet ID image',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                width: double.infinity,
                height: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    idUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Text(
                            'Error loading pet ID image',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tap the image to view in full screen',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  // Share the pet ID image
                  await Share.share(
                    'Check out my pet ID for $petName!',
                    subject: 'Pet ID for $petName',
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error sharing pet ID: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text(
                'Share Pet ID',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA800),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                try {
                  // Show physical ID request form dialog
                  final requestData = await showDialog<Map<String, String>>(
                    context: context,
                    builder: (context) => PhysicalIdRequestDialog(petName: petName),
                  );

                  if (requestData != null) {
                    // Create a physical ID request document
                    final authService = context.read<AuthService>();
                    final currentUserId = authService.currentUser?.id;
                    if (currentUserId == null) {
                      throw Exception('User not authenticated');
                    }

                    final physicalIdData = {
                      'userId': currentUserId,
                      'petName': petName,
                      'petIdUrl': idUrl,
                      'fullName': requestData['fullName'],
                      'phoneNumber': requestData['phoneNumber'],
                      'address': requestData['address'],
                      'zipCode': requestData['zipCode'],
                      'price': 20.0,
                      'status': 'pending',
                      'requestedAt': FieldValue.serverTimestamp(),
                    };

                    await FirebaseFirestore.instance
                        .collection('physicalPetIds')
                        .add(physicalIdData);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Physical pet ID request submitted successfully! You will be contacted for payment.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error requesting physical pet ID: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.card_membership, color: Color(0xFFFFA800)),
              label: const Text(
                'Request a Physical Pet ID',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFA800),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFA800),
                side: const BorderSide(color: Color(0xFFFFA800), width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pet ID Processing Page - shows when pet ID is being made
class PetIdProcessingPage extends StatelessWidget {
  final String petName;

  const PetIdProcessingPage({
    Key? key,
    required this.petName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3A1A0B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/pet_id_cat.png',
              width: 260,
              height: 260,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'Your pet ID is being processed and made, please remain patient',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF3A1A0B),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierColor: Colors.black.withOpacity(0.9),
                  builder: (context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.zero,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.transparent,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {}, // Prevent closing when tapping the image
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                  child: Container(
                                    color: Colors.white.withOpacity(0.05),
                                    padding: const EdgeInsets.all(24),
                                    child: Image.asset(
                                      'assets/images/card_example.PNG',
                                      fit: BoxFit.contain,
                                      width: 480,
                                      height: 320,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFFA800), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'View an example',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFFFA800),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}