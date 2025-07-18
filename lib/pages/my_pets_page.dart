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

// Helper to parse color string to Color
Color _parseColor(String colorString) {
  // Flutter's Color.toString() outputs 'Color(0xff123456)'
  final hexMatch = RegExp(r'0x[a-fA-F0-9]{8}').firstMatch(colorString);
  if (hexMatch != null) {
    return Color(int.parse(hexMatch.group(0)!));
  }
  // fallback
  return const Color(0xFFF59E0B);
}

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({super.key});

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(
    viewportFraction: 0.92,
  );
  int _currentPetPage = 0;
  List<Pet> _pets = [];
  bool _isLoading = true;
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
        setState(() {
          // Check if this is a new pet being added
          final isNewPet = pets.length > _pets.length;
          _pets = pets;
          _isLoading = false;
          
          // If a new pet was added, animate to it
          if (isNewPet && _pageController.hasClients) {
            // Animate to the new pet (which will be at the start since we order by createdAt desc)
              _pageController.animateToPage(
              0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
        });
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
                      child: _buildInfoBox(
                        pet.gender ?? 'Unknown',
                        Colors.blue[50]!,
                        Icons.pets,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoBox(
                        pet.age != null
                            ? (pet.age < 0
                                ? '${-pet.age} ${-pet.age == 1 ? 'month' : 'months'}'
                                : '${pet.age} ${pet.age == 1 ? 'year' : 'years'}')
                            : 'Unknown',
                        const Color(0xFFFFF3E0),
                        Icons.cake,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoBox(
                        pet.weight != null ? '${pet.weight!.toStringAsFixed(1)}kg' : 'Unknown',
                        Colors.green[50]!,
                        Icons.monitor_weight,
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
    if (_isLoading) {
      return const Center(child: SpinningLoader(color: Colors.orange));
    }

    if (_pets.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
          children: [
            SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _pets.length + 1, // +1 for add button
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final pageOffset = (index - (_pageController.page ?? 0));
              final scale = 1.0 - (pageOffset.abs() * 0.1);

              // Add pet button
              if (index == _pets.length) {
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

              final pet = _pets[index];
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
        if (_pets.isNotEmpty && _currentPetPage < _pets.length)
          Expanded(
            child: AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                if (_pageController.position.haveDimensions) {
                  final page = _pageController.page ?? 0;
                  final pageOffset = (page - _currentPetPage);
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
                child: _buildPetDetailsPanel(_pets[_currentPetPage]),
                ),
              ),
            ),
          ],
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
                            itemCount: _pets.length,
                            itemBuilder: (context, index) {
                              final pet = _pets[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 24,
                                  child: Icon(Icons.pets, color: _parseColor(pet.color)),
                                ),
                                title: Text(pet.name),
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
                                                      Text('Delete Pet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
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
                                            _pets.removeAt(index);
                                          });
                                          setState(() {}); // Also update main page
                                        }
                                      },
                                    ),
                                  ],
                                ),
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
    if (_pets.isEmpty) {
      await showDialog(
        context: context,
        builder: (context) => const ReportMissingPetDialog(),
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
                          itemCount: _pets.length,
                          itemBuilder: (context, index) {
                            final pet = _pets[index];
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
                                    builder: (context) => ReportMissingPetDialog(pet: pet),
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
    super.dispose();
  }

  void _onPageScroll() {
    final page = _pageController.page ?? 0;
    if (page != _currentPetPage) {
      setState(() => _currentPetPage = page.round());
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
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