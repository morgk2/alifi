
import 'package:alifi/services/auth_service.dart';
import 'package:alifi/services/database_service.dart';
import 'package:alifi/services/chargily_pay_service.dart';
import 'package:alifi/services/payment_status_service.dart';
import 'package:alifi/widgets/chargily_payment_webview.dart';
import 'package:alifi/pages/subscription_success_page.dart';
import 'package:alifi/pages/payment_failed_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:alifi/pages/page_container.dart';

class VetSignUpPage extends StatefulWidget {
  const VetSignUpPage({super.key});

  @override
  State<VetSignUpPage> createState() => _VetSignUpPageState();
}

class _VetSignUpPageState extends State<VetSignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController clinicLocationController =
      TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isValid = false;

  void _validate() {
    setState(() {
      isValid = firstNameController.text.trim().isNotEmpty &&
          lastNameController.text.trim().isNotEmpty &&
          clinicNameController.text.trim().isNotEmpty &&
          clinicLocationController.text.trim().isNotEmpty &&
          cityController.text.trim().isNotEmpty &&
          phoneController.text.trim().isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    firstNameController.addListener(_validate);
    lastNameController.addListener(_validate);
    clinicNameController.addListener(_validate);
    clinicLocationController.addListener(_validate);
    cityController.addListener(_validate);
    phoneController.addListener(_validate);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    clinicNameController.dispose();
    clinicLocationController.dispose();
    cityController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.35;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Image.asset(
                    'assets/images/vet_3d.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sign up as a vet',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4092FF),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'to sign up as a vet in alifi, you need to provide us with these information. all information must be accurate',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _CustomTextField(
                          hint: 'First name', controller: firstNameController),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CustomTextField(
                          hint: 'Last name', controller: lastNameController),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _CustomTextField(
                    hint: 'Your clinic name', controller: clinicNameController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _CustomTextField(
                          hint: 'Your clinic location',
                          controller: clinicLocationController),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CustomTextField(
                          hint: 'City', controller: cityController),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _CustomTextField(
                    hint: 'Phone number',
                    controller: phoneController,
                    isPhone: true),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isValid
                        ? () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        VetSignUpSummaryPage(
                                  firstName: firstNameController.text,
                                  lastName: lastNameController.text,
                                  clinicName: clinicNameController.text,
                                  clinicLocation: clinicLocationController.text,
                                  city: cityController.text,
                                  phone: phoneController.text,
                                ),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.ease;
                                  final tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4092FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text.rich(
                  TextSpan(
                    text: 'By continuing, you agree to our ',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VetSignUpSummaryPage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String clinicName;
  final String clinicLocation;
  final String city;
  final String phone;
  const VetSignUpSummaryPage(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.clinicName,
      required this.clinicLocation,
      required this.city,
      required this.phone});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.28;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'assets/images/vet_3d2.png',
                width: logoWidth,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Finishing things up!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4092FF),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: DottedBorder(
                color: const Color(0xFFBFD8F9),
                strokeWidth: 1.5,
                dashPattern: const [6, 3],
                borderType: BorderType.RRect,
                radius: const Radius.circular(16),
                padding: EdgeInsets.zero,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$firstName, $lastName',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(clinicName,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(
                                '${clinicLocation.isNotEmpty ? clinicLocation + ', ' : ''}$city',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(phone,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: Image.asset(
                          'assets/images/logo_cropped.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          VetSubscriptionPage(
                        firstName: firstName,
                        lastName: lastName,
                        clinicName: clinicName,
                        clinicLocation: clinicLocation,
                        city: city,
                        phone: phone,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        final tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4092FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VetSubscriptionPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String clinicName;
  final String clinicLocation;
  final String city;
  final String phone;
  const VetSubscriptionPage(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.clinicName,
      required this.clinicLocation,
      required this.city,
      required this.phone});

  @override
  State<VetSubscriptionPage> createState() => _VetSubscriptionPageState();
}

class _VetSubscriptionPageState extends State<VetSubscriptionPage> {
  int selected = 0;
  late PageController _pageController;

  final List<Map<String, dynamic>> offers = [
    {
      'title': 'alifi verified',
      'price': '900 DZD',
      'features': [
        'Adds your clinic to our the map',
        'Special marking for your clinic in the map',
        'Get patients to book appointments with you through the app',
        'Manage your schedule and appointments through the app',
      ],
    },
    {
      'title': 'alifi affiliated',
      'price': '1200 DZD',
      'features': [
        'Adds your clinic to our the map',
        'Even more special marking for your clinic in the map',
        'Get patients to book appointments with you through the app',
        'Manage your schedule and appointments through the app',
        'Have a verification badge on your profile and on the map',
        'Appear first on the search (when there\'s no favorite near)',
      ],
    },
    {
      'title': 'alifi favorite',
      'price': '2000 DZD',
      'features': [
        'Adds your clinic to our the map',
        'Get the most special marking for your clinic in the map',
        'Get patients to book appointments with you through the app',
        'Manage your schedule and appointments through the app',
        'Have a verification badge on your profile and on the map',
        'Appear on the homescreen when close',
        'Appear first on the search',
        'Get to post on homescreen',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: selected,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.28;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8FBFF),
                Colors.white,
              ],
            ),
          ),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                const SizedBox(height: 40),
                                // Compact hero section
                Column(
                  children: [
                    Image.asset(
                      'assets/images/vet_3d2.png',
                      width: logoWidth * 0.6,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Almost there!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1a1a1a),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose your plan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              // Swipable cards with navigation
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          selected = index;
                        });
                      },
                      itemCount: 3,
                      itemBuilder: (context, i) {
                        final isSelected = selected == i;
                        final isFavorite = i == 2;
                        final offer = offers[i];
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF4092FF)
                                    : Colors.grey.shade200,
                                width: isSelected ? 2.5 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected 
                                      ? const Color(0xFF4092FF).withOpacity(0.15)
                                      : Colors.black.withOpacity(0.04),
                                  blurRadius: isSelected ? 20 : 8,
                                  offset: Offset(0, isSelected ? 8 : 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Popular badge for favorite plan
                                if (isFavorite)
                                  Positioned(
                                    top: 0,
                                    right: 20,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12, 
                                        vertical: 6,
                                      ),
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                                        ),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'MOST POPULAR',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header with title and price
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  offer['title'],
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: isFavorite
                                                        ? const Color(0xFFFF8F00)
                                                        : const Color(0xFF1a1a1a),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Perfect for ${i == 0 ? 'small' : i == 1 ? 'growing' : 'established'} practices',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                offer['price'],
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF4092FF),
                                                ),
                                              ),
                                              Text(
                                                'per month',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[500],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Features list - made more compact
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: offer['features'].map<Widget>((feature) => Padding(
                                              padding: const EdgeInsets.only(bottom: 8),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.only(top: 2),
                                                    width: 16,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF4092FF).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Icon(
                                                      Icons.check,
                                                      size: 12,
                                                      color: Color(0xFF4092FF),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      feature,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[700],
                                                        height: 1.3,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )).toList(),
                                          ),
                                        ),
                                      ),
                                      
                                      if (isSelected) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4092FF).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF4092FF),
                                                size: 18,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Selected',
                                                style: TextStyle(
                                                  color: Color(0xFF4092FF),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Navigation arrows
                    Positioned(
                      left: 10,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: selected > 0 ? () {
                            _pageController.animateToPage(
                              selected - 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } : null,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(selected > 0 ? 0.9 : 0.5),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.chevron_left,
                              color: selected > 0 ? const Color(0xFF4092FF) : Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    Positioned(
                      right: 10,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: selected < 2 ? () {
                            _pageController.animateToPage(
                              selected + 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } : null,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(selected < 2 ? 0.9 : 0.5),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: selected < 2 ? const Color(0xFF4092FF) : Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
                            // Compact bottom section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Compact price summary
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4092FF).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              offers[selected]['title'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1a1a1a),
                              ),
                            ),
                            Text(
                              offers[selected]['price'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4092FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  VetCheckoutPage(
                            selectedOffer: offers[selected],
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            clinicName: widget.clinicName,
                            clinicLocation: widget.clinicLocation,
                            city: widget.city,
                            phone: widget.phone,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            final tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4092FF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                            'Continue to Payment',
                      style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                      ),
                    ),
                        ),
                      ),
                    ],
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

class VetCheckoutPage extends StatefulWidget {
  final Map<String, dynamic> selectedOffer;
  final String firstName;
  final String lastName;
  final String clinicName;
  final String clinicLocation;
  final String city;
  final String phone;
  const VetCheckoutPage(
      {super.key,
      required this.selectedOffer,
      required this.firstName,
      required this.lastName,
      required this.clinicName,
      required this.clinicLocation,
      required this.city,
      required this.phone});

  @override
  State<VetCheckoutPage> createState() => _VetCheckoutPageState();
}

class _VetCheckoutPageState extends State<VetCheckoutPage> {
  int _selectedPaymentIndex = -1;
  bool _isProcessing = false;
  late ChargilyPayService _chargilyService;
  late PaymentStatusService _paymentStatusService;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'CIB e-payment', 'icon': 'assets/images/cib_logo.png'},
    {'name': 'EDAHABIA', 'icon': 'assets/images/sb_logo.png'},
  ];

  @override
  void initState() {
    super.initState();
    _chargilyService = ChargilyPayService();
    _chargilyService.initialize();
    _paymentStatusService = PaymentStatusService();
  }

  void _checkout() async {
    print('🔍 [Checkout] Button pressed! _selectedPaymentIndex: $_selectedPaymentIndex');
    
    if (_selectedPaymentIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method first!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final method = _paymentMethods[_selectedPaymentIndex];
    print('🔍 [Checkout] Selected method: ${method['name']}');
    
    if (method['name'] == 'CIB e-payment' || method['name'] == 'EDAHABIA') {
      // Map display names to API method names
      String apiMethod = method['name'] == 'CIB e-payment' ? 'CIB' : 'EDAHABIA';
      await _processChargilyPayment(apiMethod);
    }
  }

  double _getSubscriptionPriceInDZD() {
    // Extract numeric value from price string (e.g., "900 DZD" -> 900.0)
    final priceString = widget.selectedOffer['price'] as String;
    final numericString = priceString.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  Future<void> _processChargilyPayment(String paymentMethod) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      
      if (user == null) {
        throw Exception('User not found');
      }

      // Generate invoice number
      final invoiceNumber = _chargilyService.generateInvoiceNumber();
      
      // Get subscription price in DZD
      final subscriptionPrice = _getSubscriptionPriceInDZD();
      
      // Create payment
      final payment = await _chargilyService.createPayment(
        client: user.displayName ?? 'Anonymous',
        clientEmail: user.email,
        invoiceNumber: invoiceNumber,
        amount: subscriptionPrice,
        currency: 'DZD',
        paymentMethod: paymentMethod,
        backUrl: 'https://alifi.app/payment/return',
        webhookUrl: 'https://slkygguxwqzwpnahnici.supabase.co/functions/v1/chargily-webhook',
        description: 'Veterinary Subscription - ${widget.selectedOffer['title']}',
        metadata: {
          'userId': user.id,
          'subscriptionType': 'veterinary',
          'planName': widget.selectedOffer['title'],
          'planPrice': subscriptionPrice,
          'orderType': 'vet_subscription',
          'firstName': widget.firstName,
          'lastName': widget.lastName,
          'clinicName': widget.clinicName,
          'clinicLocation': widget.clinicLocation,
          'city': widget.city,
          'phone': widget.phone,
        },
      );

      // Navigate to payment webview
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChargilyPaymentWebView(
              checkoutUrl: payment['checkout_url'],
              backUrl: 'https://alifi.app/payment/return',
              onPaymentComplete: (status) {
                _handlePaymentResult(status, payment['id'], subscriptionPrice);
              },
              onPaymentError: (error) {
                _handlePaymentError(error, subscriptionPrice);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _handlePaymentResult(String status, String paymentId, double amount) {
    Navigator.of(context).pop(); // Close webview
    
    if (status == 'success') {
      // Start listening for payment status changes
      _listenForPaymentStatus(paymentId, amount);
    } else if (status == 'cancelled') {
      // Navigate to failed page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentFailedPage(
            amount: amount,
            paymentMethod: _paymentMethods[_selectedPaymentIndex]['name'],
            errorMessage: 'Payment was cancelled',
            onRetry: () {
              Navigator.of(context).pop();
              _processChargilyPayment(_paymentMethods[_selectedPaymentIndex]['name']);
            },
          ),
        ),
      );
    }
  }

  void _listenForPaymentStatus(String paymentId, double amount) {
    print('Starting payment status monitoring for: $paymentId');
    
    // Show loading dialog while checking payment status
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Payment icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF4092FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Color(0xFF4092FF),
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Processing Subscription',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Please wait while we verify your payment',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Loading indicator
              const CupertinoActivityIndicator(
                radius: 16,
                color: Color(0xFF4092FF),
              ),
              const SizedBox(height: 16),
              
              // Status text
              Text(
                'Verifying payment status...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // First check if payment record exists
    _paymentStatusService.paymentExists(paymentId).then((exists) {
      if (!exists) {
        print('Payment record not found, starting polling...');
        Navigator.of(context).pop(); // Close loading dialog
        _pollVetPaymentStatus(paymentId, amount);
        return;
      }
    });

    // Listen for payment status changes
    _paymentStatusService.watchPaymentStatus(paymentId).listen(
      (paymentData) async {
        print('Received payment data in stream: ${paymentData?['status']}');
        
        if (paymentData != null && paymentData['status'] == 'paid') {
          // Payment is successful
          print('Subscription payment confirmed as paid!');
          Navigator.of(context).pop(); // Close loading dialog
          
          // Create vet request in Firestore
          await _createVetSubscriptionRequest(paymentData);
          
          // Navigate to success page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SubscriptionSuccessPage(
                amount: amount,
                paymentMethod: _paymentMethods[_selectedPaymentIndex]['name'],
                orderId: paymentId,
                subscriptionType: 'veterinary',
                planName: widget.selectedOffer['title'],
                subscriptionDetails: {
                  'clinicName': widget.clinicName,
                  'clinicLocation': widget.clinicLocation,
                  'city': widget.city,
                  'phone': widget.phone,
                },
              ),
            ),
          );
        } else if (paymentData != null && paymentData['status'] == 'failed') {
          // Payment failed
          print('Subscription payment failed');
          Navigator.of(context).pop(); // Close loading dialog
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PaymentFailedPage(
                amount: amount,
                paymentMethod: _paymentMethods[_selectedPaymentIndex]['name'],
                errorMessage: 'Payment failed',
                onRetry: () {
                  Navigator.of(context).pop();
                  String apiMethod = _paymentMethods[_selectedPaymentIndex]['name'] == 'CIB e-payment' ? 'CIB' : 'EDAHABIA';
                  _processChargilyPayment(apiMethod);
                },
              ),
            ),
          );
        }
      },
      onError: (error) {
        print('Error in payment status stream: $error');
        // Fallback to polling if streaming fails
        Navigator.of(context).pop(); // Close loading dialog
        _pollVetPaymentStatus(paymentId, amount);
      },
    );

    // Set a shorter timeout and start polling immediately as backup
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        print('Stream timeout, starting polling as backup...');
        Navigator.of(context).pop(); // Close loading dialog
        _pollVetPaymentStatus(paymentId, amount);
      }
    });
  }

  void _pollVetPaymentStatus(String paymentId, double amount) async {
    print('Starting polling for payment: $paymentId');
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Payment icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.sync,
                  color: Colors.orange.shade600,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Verifying Subscription',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Checking payment status manually',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Loading indicator
              CupertinoActivityIndicator(
                radius: 16,
                color: Colors.orange.shade600,
              ),
              const SizedBox(height: 16),
              
              // Status text
              Text(
                'Please wait while we verify your payment',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Poll for payment status
    final paymentData = await _paymentStatusService.pollPaymentStatus(paymentId, maxAttempts: 15);
    
    if (mounted) {
      Navigator.of(context).pop(); // Close loading dialog
      
      if (paymentData != null && paymentData['status'] == 'paid') {
        // Payment is successful
        print('Subscription payment confirmed as paid via polling!');
        
        // Create vet request in Firestore
        await _createVetSubscriptionRequest(paymentData);
        
        // Navigate to success page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SubscriptionSuccessPage(
              amount: amount,
              paymentMethod: _paymentMethods[_selectedPaymentIndex]['name'],
              orderId: paymentId,
              subscriptionType: 'veterinary',
              planName: widget.selectedOffer['title'],
              subscriptionDetails: {
                'clinicName': widget.clinicName,
                'clinicLocation': widget.clinicLocation,
                'city': widget.city,
                'phone': widget.phone,
              },
            ),
          ),
        );
      } else {
        // Payment verification failed
        _handlePaymentError('Payment verification failed', amount);
      }
    }
  }

  Future<void> _createVetSubscriptionRequest(Map<String, dynamic> paymentData) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final user = authService.currentUser;
      
      if (user != null) {
        // Create the vet request record for tracking
        await FirebaseFirestore.instance.collection('vet_requests').add({
          'userId': user.id,
          'firstName': widget.firstName,
          'lastName': widget.lastName,
          'clinicName': widget.clinicName,
          'clinicLocation': widget.clinicLocation,
          'city': widget.city,
          'phone': widget.phone,
          'subscription': widget.selectedOffer['title'],
          'price': widget.selectedOffer['price'],
          'status': 'paid',
          'paymentId': paymentData['id'],
          'paymentMethod': _paymentMethods[_selectedPaymentIndex]['name'],
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('Vet subscription request created successfully');

        // Activate the vet account with subscription
        final subscriptionPrice = _getSubscriptionPriceInDZD();
        await databaseService.convertUserToVetOrStore(
          userId: user.id,
          accountType: 'vet',
          firstName: widget.firstName,
          lastName: widget.lastName,
          businessName: widget.clinicName,
          businessLocation: widget.clinicLocation,
          city: widget.city,
          phone: widget.phone,
          subscriptionPlan: widget.selectedOffer['title'],
          amount: subscriptionPrice,
          currency: 'DZD',
          paymentMethod: _paymentMethods[_selectedPaymentIndex]['name'],
        );
        print('Vet account activated successfully with subscription: ${widget.selectedOffer['title']}');

        // Refresh user data to reflect the account type change
        await authService.refreshUserData();
        print('User data refreshed after vet account activation');
      }
    } catch (e) {
      print('Error creating vet subscription request or activating account: $e');
      // Don't rethrow - we still want to show success to user even if activation fails
      // The payment was successful, activation can be done manually if needed
    }
  }

  void _handlePaymentError(String error, double amount) {
    Navigator.of(context).pop(); // Close webview
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentFailedPage(
          amount: amount,
          paymentMethod: _paymentMethods[_selectedPaymentIndex]['name'],
          errorMessage: error,
          onRetry: () {
            Navigator.of(context).pop();
            _processChargilyPayment(_paymentMethods[_selectedPaymentIndex]['name']);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Complete Subscription',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Subscription Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4092FF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.local_hospital,
                                  color: Color(0xFF4092FF),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Veterinary Subscription',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.selectedOffer['title'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4092FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.selectedOffer['price'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'What\'s included:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List<Widget>.from(
                            (widget.selectedOffer['features'] as List<dynamic>)
                                .map((feature) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF4092FF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              feature,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Payment Methods Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Choose Payment Method',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // CIB Payment Card
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPaymentIndex = 0;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _selectedPaymentIndex == 0 
                                    ? const Color(0xFF4092FF).withOpacity(0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _selectedPaymentIndex == 0 
                                      ? const Color(0xFF4092FF)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/images/cib_logo.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(Icons.payment, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'CIB e-payment',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedPaymentIndex == 0 
                                                ? const Color(0xFF4092FF)
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Pay securely with your CIB card',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedScale(
                                    scale: _selectedPaymentIndex == 0 ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4092FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // EDAHABIA Payment Card
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPaymentIndex = 1;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _selectedPaymentIndex == 1 
                                    ? const Color(0xFF4092FF).withOpacity(0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _selectedPaymentIndex == 1 
                                      ? const Color(0xFF4092FF)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/images/sb_logo.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(Icons.payment, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'EDAHABIA',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedPaymentIndex == 1 
                                                ? const Color(0xFF4092FF)
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Pay with your EDAHABIA card',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedScale(
                                    scale: _selectedPaymentIndex == 1 ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4092FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Powered by Chargily Pay
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Powered by',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SvgPicture.asset(
                                  'assets/images/chargilypaylogo.svg',
                                  height: 32,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF6B46C1),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Total amount display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4092FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF4092FF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subscription Price',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      widget.selectedOffer['price'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4092FF),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Payment button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _checkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4092FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CupertinoActivityIndicator(
                                radius: 10,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Processing Payment...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedPaymentIndex == -1 
                                  ? 'Select Payment Method'
                                  : 'Complete Subscription',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VetCCPConfirmationPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String clinicName;
  final String clinicLocation;
  final String city;
  final String phone;
  final Map<String, dynamic> selectedOffer;
  
  const VetCCPConfirmationPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.clinicName,
    required this.clinicLocation,
    required this.city,
    required this.phone,
    required this.selectedOffer,
  });

  @override
  State<VetCCPConfirmationPage> createState() => _VetCCPConfirmationPageState();
}

class _VetCCPConfirmationPageState extends State<VetCCPConfirmationPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/alifi_logo.png', height: 80),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome, Doctor ${widget.firstName}!',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your account has been successfully upgraded to a veterinarian account. You can now manage appointments, view patients, and access all vet features.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 32),
              if (_isProcessing)
                const CircularProgressIndicator(color: Colors.blue)
              else
                ElevatedButton(
                  onPressed: _completeConversion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Continue to Dashboard',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeConversion() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final authService = context.read<AuthService>();
      final user = authService.currentUser;
      
      if (user == null) {
        throw Exception('User not found');
      }

      // Extract price from the offer (remove "DZD" and convert to double)
      final priceString = widget.selectedOffer['price'].toString().replaceAll(' DZD', '').replaceAll('DZD', '').trim();
      final amount = double.tryParse(priceString) ?? 900.0;

      // Convert user to vet account
      await DatabaseService().convertUserToVetOrStore(
        userId: user.id,
        accountType: 'vet',
        firstName: widget.firstName,
        lastName: widget.lastName,
        businessName: widget.clinicName,
        businessLocation: widget.clinicLocation,
        city: widget.city,
        phone: widget.phone,
        subscriptionPlan: widget.selectedOffer['title'],
        amount: amount,
        currency: 'DZD',
        paymentMethod: 'CCP',
      );

      // Update the current user in AuthService
      final updatedUser = await DatabaseService().getUser(user.id);
      if (updatedUser != null) {
        authService.updateCurrentUser(updatedUser);
      }

      if (mounted) {
        // Navigate to home page and show success message
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, Doctor ${widget.firstName}! Your vet account is now active.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Trigger location setup check after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            // Access the PageContainer to trigger location setup
            final pageContainerState = pageContainerKey.currentState;
            if (pageContainerState != null) {
              pageContainerState.checkLocationSetup();
            }
          }
        });
      }
    } catch (e) {
      print('Error completing vet conversion: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing conversion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final bool isPhone;
  const _CustomTextField(
      {required this.hint, this.controller, this.isPhone = false});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.number : TextInputType.text,
      inputFormatters:
          isPhone ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF4092FF)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
} 