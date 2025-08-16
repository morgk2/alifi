import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_fonts.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  List<HelpItem> _helpItems = [];
  String _selectedCategory = '';
  String _searchQuery = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_helpItems.isEmpty) {
      _helpItems = [
        HelpItem(
          question: AppLocalizations.of(context)!.howToBookAppointment,
          answer: AppLocalizations.of(context)!.bookAppointmentInstructions,
          category: AppLocalizations.of(context)!.appointments,
        ),
        HelpItem(
          question: AppLocalizations.of(context)!.howToAddPets,
          answer: AppLocalizations.of(context)!.addPetsInstructions,
          category: AppLocalizations.of(context)!.pets,
        ),
        HelpItem(
          question: AppLocalizations.of(context)!.howToReportLostPet,
          answer: AppLocalizations.of(context)!.reportLostPetInstructions,
          category: AppLocalizations.of(context)!.lostPets,
        ),
        HelpItem(
          question: AppLocalizations.of(context)!.howToOrderPetSupplies,
          answer: AppLocalizations.of(context)!.orderPetSuppliesInstructions,
          category: AppLocalizations.of(context)!.store,
        ),
        HelpItem(
          question: AppLocalizations.of(context)!.howToContactCustomerSupport,
          answer: AppLocalizations.of(context)!.contactCustomerSupportInstructions,
          category: AppLocalizations.of(context)!.support,
        ),
        HelpItem(
          question: AppLocalizations.of(context)!.howToChangeAccountSettings,
          answer: AppLocalizations.of(context)!.changeAccountSettingsInstructions,
          category: AppLocalizations.of(context)!.account,
        ),
        HelpItem(
          question: AppLocalizations.of(context)!.howToFindVeterinariansNearMe,
          answer: AppLocalizations.of(context)!.findVeterinariansInstructions,
          category: AppLocalizations.of(context)!.appointments,
        ),
        HelpItem(
          question: AppLocalizations.of(context)!.howToCancelAppointment,
          answer: AppLocalizations.of(context)!.cancelAppointmentInstructions,
          category: AppLocalizations.of(context)!.appointments,
        ),
      ];
      _selectedCategory = AppLocalizations.of(context)!.all;
    }
  }

  List<HelpItem> get _filteredItems {
    return _helpItems.where((item) {
      final matchesSearch = item.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == AppLocalizations.of(context)!.all || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> get _categories {
    final categories = _helpItems.map((item) => item.category).toSet().toList();
    categories.insert(0, AppLocalizations.of(context)!.all);
    return categories;
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.helpCenter,
          style: TextStyle(fontFamily: context.titleFont,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchForHelp,
                    prefixIcon: const Icon(CupertinoIcons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _CategoryChip(
                          label: category,
                          isSelected: _selectedCategory == category,
                          onTap: () => _filterByCategory(category),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Results Section
          Expanded(
            child: _filteredItems.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return _HelpItemCard(item: _filteredItems[index]);
                    },
                  ),
          ),
          // Contact Support Section
          _buildContactSupportSection(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.question_circle,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noResultsFound,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.tryAdjustingSearchOrCategoryFilter,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSupportSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.stillNeedHelp,
            style: TextStyle(fontFamily: context.titleFont,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.contactSupportTeamForPersonalizedAssistance,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ContactOptionCard(
                  icon: CupertinoIcons.mail,
                  title: AppLocalizations.of(context)!.email,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Text(AppLocalizations.of(context)!.emailSupportComingSoon),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                        ],
                      ),
                    );
                  },
                  label: Text(AppLocalizations.of(context)!.email),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ContactOptionCard(
                  icon: CupertinoIcons.chat_bubble_2,
                  title: AppLocalizations.of(context)!.liveChat,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Text(AppLocalizations.of(context)!.liveChatComingSoon),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                        ],
                      ),
                    );
                  },
                  label: Text(AppLocalizations.of(context)!.liveChat),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4092FF) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4092FF) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _HelpItemCard extends StatelessWidget {
  final HelpItem item;

  const _HelpItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          item.question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4092FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.category,
              style: TextStyle(
                color: const Color(0xFF4092FF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              item.answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget label;

  const _ContactOptionCard({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xFF4092FF),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            label,
          ],
        ),
      ),
    );
  }
}

class HelpItem {
  final String question;
  final String answer;
  final String category;

  HelpItem({
    required this.question,
    required this.answer,
    required this.category,
  });
} 