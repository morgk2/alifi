import 'package:flutter/material.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I book an appointment with a veterinarian?',
      answer: 'To book an appointment, go to the "Find Vet" section, search for veterinarians in your area, select one, and tap "Book Appointment". You can choose your preferred date and time.',
      category: 'Appointments',
    ),
    FAQItem(
      question: 'How do I add my pets to the app?',
      answer: 'Go to "My Pets" in the bottom navigation, tap the "+" button, and fill in your pet\'s information including name, species, breed, and age.',
      category: 'Pets',
    ),
    FAQItem(
      question: 'How do I report a lost pet?',
      answer: 'Navigate to "Lost Pets" section, tap "Report Lost Pet", fill in the details including photos, location, and contact information.',
      category: 'Lost Pets',
    ),
    FAQItem(
      question: 'How do I order pet supplies?',
      answer: 'Go to the "Store" section, browse products, add items to cart, and proceed to checkout with your payment method.',
      category: 'Store',
    ),
    FAQItem(
      question: 'How do I contact customer support?',
      answer: 'You can contact us through the "Report a Bug" feature in Settings, or email us at support@alifi.com.',
      category: 'Support',
    ),
    FAQItem(
      question: 'How do I change my account settings?',
      answer: 'Go to Settings, tap on the setting you want to change, and follow the prompts to update your information.',
      category: 'Account',
    ),
    FAQItem(
      question: 'How do I find veterinarians near me?',
      answer: 'Use the "Find Vet" feature and allow location access to see veterinarians in your area, or search by city/zip code.',
      category: 'Appointments',
    ),
    FAQItem(
      question: 'How do I cancel an appointment?',
      answer: 'Go to "My Appointments", find the appointment you want to cancel, tap on it, and select "Cancel Appointment".',
      category: 'Appointments',
    ),
  ];

  String _selectedCategory = 'All';
  List<FAQItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _faqItems;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFAQs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _faqItems.where((item) => 
          _selectedCategory == 'All' || item.category == _selectedCategory
        ).toList();
      } else {
        _filteredItems = _faqItems.where((item) => 
          (item.question.toLowerCase().contains(query.toLowerCase()) ||
           item.answer.toLowerCase().contains(query.toLowerCase())) &&
          (_selectedCategory == 'All' || item.category == _selectedCategory)
        ).toList();
      }
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filteredItems = _faqItems.where((item) => 
        category == 'All' || item.category == category
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Help Center',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          
          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterFAQs,
              decoration: InputDecoration(
                hintText: 'Search for help...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Category Filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == 'All',
                  onTap: () => _filterByCategory('All'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Appointments',
                  isSelected: _selectedCategory == 'Appointments',
                  onTap: () => _filterByCategory('Appointments'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Pets',
                  isSelected: _selectedCategory == 'Pets',
                  onTap: () => _filterByCategory('Pets'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Store',
                  isSelected: _selectedCategory == 'Store',
                  onTap: () => _filterByCategory('Store'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Account',
                  isSelected: _selectedCategory == 'Account',
                  onTap: () => _filterByCategory('Account'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Support',
                  isSelected: _selectedCategory == 'Support',
                  onTap: () => _filterByCategory('Support'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // FAQ List
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or category filter',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return _FAQCard(faq: _filteredItems[index]);
                    },
                  ),
          ),
          
          const SizedBox(height: 16),
          
          // Contact Support
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildContactSupportCard(),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContactSupportCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
                         Icon(
               Icons.support_agent,
               size: 48,
               color: Colors.orange[600],
             ),
            const SizedBox(height: 16),
            const Text(
              'Still need help?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contact our support team for personalized assistance',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Open email client
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email support coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Email'),
                                         style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.orange,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 12),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(8),
                       ),
                     ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Open chat support
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Live chat coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('Live Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
           color: isSelected ? Colors.orange : Colors.white,
           borderRadius: BorderRadius.circular(20),
           border: Border.all(
             color: isSelected ? Colors.orange : Colors.grey[300]!,
             width: 1,
           ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _FAQCard extends StatefulWidget {
  final FAQItem faq;

  const _FAQCard({required this.faq});

  @override
  State<_FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<_FAQCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.faq.question,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 4),
                                                 Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: Colors.orange.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: Text(
                             widget.faq.category,
                             style: TextStyle(
                               fontSize: 12,
                               color: Colors.orange[600],
                               fontWeight: FontWeight.w500,
                             ),
                           ),
                         ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Colors.grey[200]),
                  const SizedBox(height: 16),
                  Text(
                    widget.faq.answer,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
} 