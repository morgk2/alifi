import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/database_service.dart';
import '../widgets/spinning_loader.dart';

class AdoptionCenterPage extends StatefulWidget {
  const AdoptionCenterPage({super.key});

  @override
  State<AdoptionCenterPage> createState() => _AdoptionCenterPageState();
}

class _AdoptionCenterPageState extends State<AdoptionCenterPage> {
  final _databaseService = DatabaseService();

  Widget _buildPetCircle(Pet pet, Color borderColor) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: pet.imageUrls.isNotEmpty
                ? Image.network(
                    pet.imageUrls.first,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.pets,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          pet.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Image.asset(
          'assets/images/back_icon.png',
          width: 24,
          height: 24,
        ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/adoption.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Adoption center',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24), // Added spacing
            // Pets near me section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.star, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Pets near me',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Search and Filter buttons
                  IconButton(
                    icon: const Icon(Icons.search),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      padding: const EdgeInsets.all(8),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.tune),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      padding: const EdgeInsets.all(8),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Pets near me horizontal list
            SizedBox(
              height: 140,
              child: StreamBuilder<List<Pet>>(
                stream: _databaseService.getNearbyPets(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: SpinningLoader(color: Colors.orange));
                  }

                  final pets = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      return _buildPetCircle(
                        pet,
                        const Color(0xFFFFB300), // Orange border
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32), // Increased spacing
            // New listings section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.star, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'New listings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Row(
                      children: [
                        Text(
                          'See all',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // New listings grid
            Expanded(
              child: StreamBuilder<List<Pet>>(
                stream: _databaseService.getNewListings(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: SpinningLoader(color: Colors.orange));
                  }

                  final pets = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      return _buildPetCircle(
                        pet,
                        const Color(0xFFFFB300), // Orange border
                      );
                    },
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