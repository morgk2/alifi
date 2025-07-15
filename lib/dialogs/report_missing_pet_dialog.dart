import 'package:flutter/material.dart';

class ReportMissingPetDialog extends StatefulWidget {
  const ReportMissingPetDialog({super.key});

  @override
  State<ReportMissingPetDialog> createState() => _ReportMissingPetDialogState();
}

class _ReportMissingPetDialogState extends State<ReportMissingPetDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController();
  DateTime _lastSeen = DateTime.now();
  TimeOfDay _lastSeenTime = TimeOfDay.now();
  String? _selectedImage;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Add pet type state
  String _selectedType = 'dog';
  final List<Map<String, dynamic>> _petTypes = [
    {'type': 'dog', 'asset': 'assets/images/dog_icon.png'},
    {'type': 'cat', 'asset': 'assets/images/cat_icon.png'},
  ];

  // For swipeable steps
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5; // Updated to include Last Seen and Reward steps

  bool get _isValid =>
      _selectedImage != null &&
      _nameController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _rewardController.dispose();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastSeen,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _lastSeen) {
      setState(() {
        _lastSeen = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _lastSeenTime,
    );
    if (picked != null && picked != _lastSeenTime) {
      setState(() {
        _lastSeenTime = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    // TODO: Implement image picking
    setState(() {
      _selectedImage = 'assets/images/placeholder_pet.jpg';
    });
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _showValidationError() {
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -1.0, end: 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset:
                    Offset(0, MediaQuery.of(context).size.height * value * 0.1),
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Please fill in all required fields (photo, name, and description)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> _showConfirmationDialog() async {
    if (!_isValid) {
      _showValidationError();
      return;
    }

    final bool? confirmed = await showDialog(
      context: context,
      barrierColor: Colors.black54,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          child: Dialog(
            elevation: 24,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.pets,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Are you sure?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This will post your missing pet report to the community.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(fontSize: 16),
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
      },
    );

    if (confirmed == true) {
      // Close the report dialog with animation
      await _animationController.reverse();
      if (!mounted) return;
      Navigator.of(context).pop();

      // Show notification banner
      if (!mounted) return;
      _showNotificationBanner(context);
    }
  }

  void _showNotificationBanner(BuildContext context) {
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -1.0, end: 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset:
                    Offset(0, MediaQuery.of(context).size.height * value * 0.1),
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.sentiment_very_dissatisfied,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Missing Pet Report Submitted',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We hope you find your pet soon! The community will be notified.',
                          style: TextStyle(
                            color: Colors.red[900],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Remove the notification after 3 seconds with fade out animation
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDialogHeight = screenHeight * 0.9;
    final maxDialogWidth = screenWidth * 0.95;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: Dialog(
              insetPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                constraints: BoxConstraints(
                  maxHeight: maxDialogHeight,
                  maxWidth: maxDialogWidth,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Report a missing pet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 420, // Fixed height for PageView
                        child: PageView(
                          controller: _pageController,
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (index) => setState(() => _currentStep = index),
                          children: [
                            // Step 1: Pet Type Selector
                            LayoutBuilder(
                              builder: (context, constraints) {
                                double availableWidth = constraints.maxWidth;
                                double circleSize = 120; // Increased from 72
                                double iconSize = 64; // Increased from 40
                                if (availableWidth < 350) {
                                  circleSize = 96; // Increased from 48
                                  iconSize = 48; // Increased from 28
                                }
                                bool showCircle = availableWidth >= 250;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Select Pet Type',
                                      style: TextStyle(
                                        fontSize: 18, // Increased from 16
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 32), // Increased from 24
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: _petTypes.map((petType) {
                                        final isSelected = _selectedType == petType['type'];
                                        return GestureDetector(
                                          onTap: () => setState(() => _selectedType = petType['type']),
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 16), // Increased from 8
                                            child: showCircle
                                                ? AnimatedContainer(
                                                    duration: const Duration(milliseconds: 200),
                                                    width: circleSize,
                                                    height: circleSize,
                                                    decoration: BoxDecoration(
                                                      color: isSelected ? Colors.red[100] : Colors.grey[200],
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: isSelected ? Colors.red : Colors.grey[400]!,
                                                        width: isSelected ? 4 : 1, // Increased from 3
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(16.0), // Increased from 8
                                                      child: Image.asset(
                                                        petType['asset'],
                                                        width: iconSize,
                                                        height: iconSize,
                                                        color: isSelected ? Colors.red : Colors.grey[700],
                                                        colorBlendMode: BlendMode.srcIn,
                                                      ),
                                                    ),
                                                  )
                                                : Image.asset(
                                                    petType['asset'],
                                                    width: iconSize,
                                                    height: iconSize,
                                                    color: isSelected ? Colors.red : Colors.grey[700],
                                                    colorBlendMode: BlendMode.srcIn,
                                                  ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                );
                              },
                            ),
                            // Step 2: Image and Name
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                    Center(
                      child: GestureDetector(
                        onTap: () => _pickImage(),
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 32,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Required',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Pet Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your pet\'s name (Required)',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Adjusted padding
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                              ],
                            ),
                            // Step 3: Description
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                                      hintText: 'Describe your pet - size, color, distinctive features... (Required)',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Adjusted padding
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                              ],
                            ),
                            // Step 4: Last seen
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                    const Text(
                      'Last seen',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${_lastSeen.month}/${_lastSeen.day}/${_lastSeen.year}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectTime(context),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _lastSeenTime.format(context),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                              ],
                            ),
                            // Step 5: Reward (optional)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                    const Text(
                      'Reward (optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _rewardController,
                                    keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                                      hintText: 'Enter reward amount in DZD (Optional)',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Adjusted padding
                          border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentStep > 0)
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
                              onPressed: _prevStep,
                            )
                          else
                            const SizedBox(width: 48),
                          Text('Step ${_currentStep + 1} of $_totalSteps'),
                          if (_currentStep < _totalSteps - 1)
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: _nextStep,
                            )
                          else
                            const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              _animationController.reverse().then((_) {
                                Navigator.of(context).pop();
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextButton(
                            onPressed: _showConfirmationDialog,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Report',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
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
      },
    );
  }
}
