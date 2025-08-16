import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AdoptionFilterPage extends StatefulWidget {
  final Map<String, dynamic>? currentFilters;

  const AdoptionFilterPage({
    super.key,
    this.currentFilters,
  });

  @override
  State<AdoptionFilterPage> createState() => _AdoptionFilterPageState();
}

class _AdoptionFilterPageState extends State<AdoptionFilterPage> {
  // Filter states
  String _selectedPetType = 'All';
  String _selectedBreed = 'All';
  String _selectedGender = 'All';
  String _selectedAgeRange = 'All';
  String _selectedPriceRange = 'All';
  String _selectedLocation = 'All';
  bool _onlyActive = true;
  bool _onlyWithPhotos = false;

  // Available options
  final List<String> _petTypes = [
    'All',
    'Dog',
    'Cat',
    'Bird',
    'Fish',
    'Rabbit',
    'Hamster',
    'Guinea Pig',
    'Other',
  ];

  final List<String> _breeds = [
    'All',
    'Mixed Breed',
    'Golden Retriever',
    'Labrador Retriever',
    'German Shepherd',
    'Bulldog',
    'Beagle',
    'Persian',
    'Siamese',
    'Maine Coon',
    'British Shorthair',
    'Other',
  ];

  final List<String> _genders = [
    'All',
    'Male',
    'Female',
  ];

  final List<String> _ageRanges = [
    'All',
    '0-1 years',
    '1-3 years',
    '3-5 years',
    '5-8 years',
    '8+ years',
  ];

  final List<String> _priceRanges = [
    'All',
    'Free',
    '0-5000 DZD',
    '5000-15000 DZD',
    '15000-30000 DZD',
    '30000+ DZD',
  ];

  final List<String> _locations = [
    'All',
    'Alger',
    'Oran',
    'Constantine',
    'Annaba',
    'Batna',
    'Setif',
    'Blida',
    'Tlemcen',
    'Djelfa',
    'Jijel',
    'Skikda',
    'Sidi Bel Abbès',
    'Guelma',
    'Médéa',
    'Mostaganem',
    'M\'Sila',
    'Mascara',
    'Ouargla',
    'El Bayadh',
    'Illizi',
    'Bordj Bou Arréridj',
    'Boumerdès',
    'El Tarf',
    'Tindouf',
    'Tissemsilt',
    'El Oued',
    'Khenchela',
    'Souk Ahras',
    'Tipaza',
    'Mila',
    'Aïn Defla',
    'Naâma',
    'Aïn Témouchent',
    'Ghardaïa',
    'Relizane',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentFilters();
  }

  void _loadCurrentFilters() {
    if (widget.currentFilters != null) {
      setState(() {
        _selectedPetType = widget.currentFilters!['petType'] ?? 'All';
        _selectedBreed = widget.currentFilters!['breed'] ?? 'All';
        _selectedGender = widget.currentFilters!['gender'] ?? 'All';
        _selectedAgeRange = widget.currentFilters!['ageRange'] ?? 'All';
        _selectedPriceRange = widget.currentFilters!['priceRange'] ?? 'All';
        _selectedLocation = widget.currentFilters!['location'] ?? 'All';
        _onlyActive = widget.currentFilters!['onlyActive'] ?? true;
        _onlyWithPhotos = widget.currentFilters!['onlyWithPhotos'] ?? false;
      });
    }
  }

  Map<String, dynamic> _getFilters() {
    return {
      'petType': _selectedPetType,
      'breed': _selectedBreed,
      'gender': _selectedGender,
      'ageRange': _selectedAgeRange,
      'priceRange': _selectedPriceRange,
      'location': _selectedLocation,
      'onlyActive': _onlyActive,
      'onlyWithPhotos': _onlyWithPhotos,
    };
  }

  void _resetFilters() {
    setState(() {
      _selectedPetType = 'All';
      _selectedBreed = 'All';
      _selectedGender = 'All';
      _selectedAgeRange = 'All';
      _selectedPriceRange = 'All';
      _selectedLocation = 'All';
      _onlyActive = true;
      _onlyWithPhotos = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Filter Listings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter options
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Pet Type'),
                    _buildFilterChips(_petTypes, _selectedPetType, (value) {
                      setState(() => _selectedPetType = value);
                    }),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Breed'),
                    _buildFilterChips(_breeds, _selectedBreed, (value) {
                      setState(() => _selectedBreed = value);
                    }),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Gender'),
                    _buildFilterChips(_genders, _selectedGender, (value) {
                      setState(() => _selectedGender = value);
                    }),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Age Range'),
                    _buildFilterChips(_ageRanges, _selectedAgeRange, (value) {
                      setState(() => _selectedAgeRange = value);
                    }),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Price Range'),
                    _buildFilterChips(_priceRanges, _selectedPriceRange, (value) {
                      setState(() => _selectedPriceRange = value);
                    }),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Location'),
                    _buildFilterChips(_locations, _selectedLocation, (value) {
                      setState(() => _selectedLocation = value);
                    }),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Additional Options'),
                    _buildSwitchOption(
                      'Only Active Listings',
                      'Show only currently available pets',
                      _onlyActive,
                      (value) => setState(() => _onlyActive = value),
                    ),
                    const SizedBox(height: 12),
                    _buildSwitchOption(
                      'Only with Photos',
                      'Show only listings with images',
                      _onlyWithPhotos,
                      (value) => setState(() => _onlyWithPhotos = value),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Apply button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).pop(_getFilters());
                  },
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selectedValue;
        return GestureDetector(
          onTap: () => onChanged(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.orange : Colors.grey[300]!,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchOption(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.orange,
            trackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
