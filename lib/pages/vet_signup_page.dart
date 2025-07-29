import 'package:alifi/main.dart';
import 'package:alifi/services/auth_service.dart';
import 'package:alifi/widgets/spinning_loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.28;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
              const SizedBox(height: 16),
              const Text(
                'Finishing things up!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4092FF),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose your offer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4092FF),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(3, (i) {
                    final isSelected = selected == i;
                    final isFavorite = i == 2;
                    final cardWidth = MediaQuery.of(context).size.width / 3.4;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The card itself
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: EdgeInsets.only(right: i < 2 ? 12 : 0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selected = i;
                                  });
                                },
                                child: AnimatedScale(
                                  scale: isSelected ? 1.08 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: AnimatedOpacity(
                                    opacity: isSelected ? 1.0 : 0.7,
                                    duration:
                                        const Duration(milliseconds: 300),
                                    child: Container(
                                      width: cardWidth,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 22),
                                      decoration: BoxDecoration(
                                        color: isFavorite
                                            ? const Color(0xFFFFF7E0)
                                            : Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF4092FF)
                                              : Colors.grey.shade300,
                                          width: 2.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        boxShadow: isFavorite
                                            ? [
                                                BoxShadow(
                                                  color: Colors.amber
                                                      .withOpacity(0.13),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                offers[i]['title'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: isFavorite
                                                      ? const Color(
                                                          0xFFFFB300)
                                                      : Colors.black87,
                                                ),
                                              ),
                                              if (isSelected)
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 8.0),
                                                  child: Icon(
                                                      Icons.check_circle,
                                                      color: Color(0xFF4092FF),
                                                      size: 22),
                                                ),
                                            ],
                                          ),
                                          // Add space for the stamp for all cards, so all cards have same height
                                          const SizedBox(height: 54),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Stamp badge at the bottom center of the favorite card, animated with the card's scale
                            if (isFavorite)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom:
                                    12, // Move the stamp up, closer to the card
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selected = 2;
                                    });
                                  },
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(
                                        begin: 1.0,
                                        end: isSelected ? 1.08 : 1.0),
                                    duration:
                                        const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: Image.asset(
                                          'assets/images/stamp.png',
                                          width: 72,
                                          height: 72,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monthly price',
                        style: TextStyle(color: Colors.grey, fontSize: 17)),
                    Text(offers[selected]['price'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: ListView.separated(
                      key: ValueKey(selected),
                      itemCount: offers[selected]['features'].length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFFE0E0E0)),
                      itemBuilder: (context, idx) {
                        final feature = offers[selected]['features'][idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  feature,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                              ),
                              if (feature.contains('info'))
                                const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Icon(Icons.info_outline,
                                      color: Colors.grey, size: 18),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: SizedBox(
                  width: 200,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'PayPal', 'icon': 'assets/images/paypal_logo.png'},
    {
      'name': 'CIB_SB',
      'icon': 'assets/images/cib_logo.png',
      'icon2': 'assets/images/sb_logo.png'
    },
    {'name': 'Visa/Mastercard', 'icon': 'assets/images/visa_mastercard.png'},
    {'name': 'Stripe', 'icon': 'assets/images/stripe_logo.png'},
    {'name': 'CCP', 'icon': null},
  ];

  void _checkout() {
    if (_selectedPaymentIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return;
    }

    final method = _paymentMethods[_selectedPaymentIndex];
    if (method['name'] == 'CCP') {
      final userId = AuthService().currentUser!.id;
      FirebaseFirestore.instance.collection('vet_requests').add({
        'userId': userId,
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'clinicName': widget.clinicName,
        'clinicLocation': widget.clinicLocation,
        'city': widget.city,
        'phone': widget.phone,
        'subscription': widget.selectedOffer['title'],
        'price': widget.selectedOffer['price'],
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const VetCCPConfirmationPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Checkout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary card
            Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.selectedOffer['title'],
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(widget.selectedOffer['price'],
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    ...List<Widget>.from(
                        (widget.selectedOffer['features'] as List<dynamic>)
                            .map((feature) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check,
                                          color: Colors.green, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text(feature,
                                              style: const TextStyle(
                                                  fontSize: 16))),
                                    ],
                                  ),
                                ))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Payment methods
            const Text('Select Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = _paymentMethods[index];
                  final isSelected = _selectedPaymentIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPaymentIndex = index;
                      });
                    },
                    child: Card(
                      elevation: isSelected ? 8 : 2,
                      shadowColor:
                          isSelected ? Colors.blue[100] : Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color:
                              isSelected ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            if (method['icon'] != null && method['name'] != 'CIB_SB')
                              Image.asset(method['icon'], width: 40)
                            else if (method['name'] == 'CIB_SB')
                              Row(
                                children: [
                                  Image.asset(method['icon'], width: 40),
                                  const SizedBox(width: 8),
                                  Image.asset(method['icon2'], width: 40),
                                ],
                              )
                            else
                              const SizedBox(width: 40),
                            const SizedBox(width: 16),
                            Expanded(child: Text(method['name'].replaceAll('_', ' & '), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _checkout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Proceed to Checkout',
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}

class VetCCPConfirmationPage extends StatelessWidget {
  const VetCCPConfirmationPage({super.key});

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
                'Thank You!',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your request to become a vet has been submitted. You will be contacted by our team shortly via phone to finalize the subscription payment.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .popUntil((route) => route.isFirst); // Go back to home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to Home',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
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