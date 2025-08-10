import 'package:alifi/main.dart';
import 'package:alifi/services/auth_service.dart';
import 'package:alifi/services/database_service.dart';
import 'package:alifi/widgets/spinning_loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:alifi/pages/page_container.dart';

class StoreSignUpPage extends StatefulWidget {
  const StoreSignUpPage({super.key});

  @override
  State<StoreSignUpPage> createState() => _StoreSignUpPageState();
}

class _StoreSignUpPageState extends State<StoreSignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController storeLocationController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isValid = false;

  void _validate() {
    setState(() {
      isValid = firstNameController.text.trim().isNotEmpty &&
          lastNameController.text.trim().isNotEmpty &&
          storeNameController.text.trim().isNotEmpty &&
          storeLocationController.text.trim().isNotEmpty &&
          cityController.text.trim().isNotEmpty &&
          phoneController.text.trim().isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    firstNameController.addListener(_validate);
    lastNameController.addListener(_validate);
    storeNameController.addListener(_validate);
    storeLocationController.addListener(_validate);
    cityController.addListener(_validate);
    phoneController.addListener(_validate);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    storeNameController.dispose();
    storeLocationController.dispose();
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
                    'assets/images/store_3d.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sign up as a store',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28a745),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'to sign up as a store in alifi, you need to provide us with these information. all information must be accurate',
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
                    hint: 'Your store name', controller: storeNameController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _CustomTextField(
                          hint: 'Your store location',
                          controller: storeLocationController),
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
                                        StoreSignUpSummaryPage(
                                  firstName: firstNameController.text,
                                  lastName: lastNameController.text,
                                  storeName: storeNameController.text,
                                  storeLocation: storeLocationController.text,
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
                      backgroundColor: const Color(0xFF28a745),
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

class StoreSignUpSummaryPage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String storeName;
  final String storeLocation;
  final String city;
  final String phone;
  const StoreSignUpSummaryPage(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.storeName,
      required this.storeLocation,
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
                'assets/images/store_3d2.png',
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
                color: Color(0xFF28a745),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: DottedBorder(
                color: const Color(0xFFa3d8b8),
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
                            Text(storeName,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(
                                '${storeLocation.isNotEmpty ? storeLocation + ', ' : ''}$city',
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
                          StoreSubscriptionPage(
                        firstName: firstName,
                        lastName: lastName,
                        storeName: storeName,
                        storeLocation: storeLocation,
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
                  backgroundColor: const Color(0xFF28a745),
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

class StoreSubscriptionPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String storeName;
  final String storeLocation;
  final String city;
  final String phone;
  const StoreSubscriptionPage(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.storeName,
      required this.storeLocation,
      required this.city,
      required this.phone});

  @override
  State<StoreSubscriptionPage> createState() => _StoreSubscriptionPageState();
}

class _StoreSubscriptionPageState extends State<StoreSubscriptionPage> {
  int selected = 0;

  final List<Map<String, dynamic>> offers = [
    {
      'title': 'alifi verified',
      'price': '900 DZD',
      'features': [
        'Adds your store to our the map',
        'Special marking for your store in the map',
        'Get customers to find your store through the app',
      ],
    },
    {
      'title': 'alifi affiliated',
      'price': '1200 DZD',
      'features': [
        'Adds your store to our the map',
        'Even more special marking for your store in the map',
        'Get customers to find your store through the app',
        'Have a verification badge on your profile and on the map',
        'Appear first on the search (when there\'s no favorite near)',
      ],
    },
    {
      'title': 'alifi favorite',
      'price': '2000 DZD',
      'features': [
        'Adds your store to our the map',
        'Get the most special marking for your store in the map',
        'Get customers to find your store through the app',
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
                  'assets/images/store_3d2.png',
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
                  color: Color(0xFF28a745),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose your offer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF28a745),
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
                                              ? const Color(0xFF28a745)
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
                                                      color:
                                                          Color(0xFF28a745),
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
                                  StoreCheckoutPage(
                            selectedOffer: offers[selected],
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            storeName: widget.storeName,
                            storeLocation: widget.storeLocation,
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
                      backgroundColor: const Color(0xFF28a745),
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

class StoreCheckoutPage extends StatefulWidget {
  final Map<String, dynamic> selectedOffer;
  final String firstName;
  final String lastName;
  final String storeName;
  final String storeLocation;
  final String city;
  final String phone;
  const StoreCheckoutPage(
      {super.key,
      required this.selectedOffer,
      required this.firstName,
      required this.lastName,
      required this.storeName,
      required this.storeLocation,
      required this.city,
      required this.phone});

  @override
  State<StoreCheckoutPage> createState() => _StoreCheckoutPageState();
}

class _StoreCheckoutPageState extends State<StoreCheckoutPage> {
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
    print('🔍 [Store Checkout] Button pressed! _selectedPaymentIndex: $_selectedPaymentIndex');
    
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
    print('🔍 [Store Checkout] Selected method: ${method['name']}');
    
    if (method['name'] == 'CCP') {
      final authService = context.read<AuthService>();
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in first!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final userId = currentUser.id;
      FirebaseFirestore.instance.collection('store_requests').add({
        'userId': userId,
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'storeName': widget.storeName,
        'storeLocation': widget.storeLocation,
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
              StoreCCPConfirmationPage(
            firstName: widget.firstName,
            lastName: widget.lastName,
            storeName: widget.storeName,
            storeLocation: widget.storeLocation,
            city: widget.city,
            phone: widget.phone,
            selectedOffer: widget.selectedOffer,
          ),
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
                          isSelected ? Colors.green[100] : Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color:
                              isSelected ? Colors.green : Colors.transparent,
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
                              const Icon(Icons.check_circle, color: Colors.green),
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
            backgroundColor: Colors.green,
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

class StoreCCPConfirmationPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String storeName;
  final String storeLocation;
  final String city;
  final String phone;
  final Map<String, dynamic> selectedOffer;
  
  const StoreCCPConfirmationPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.storeName,
    required this.storeLocation,
    required this.city,
    required this.phone,
    required this.selectedOffer,
  });

  @override
  State<StoreCCPConfirmationPage> createState() => _StoreCCPConfirmationPageState();
}

class _StoreCCPConfirmationPageState extends State<StoreCCPConfirmationPage> {
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
                    color: Colors.green),
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome, ${widget.firstName}!',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your account has been successfully upgraded to a store account. You can now manage products, view orders, and access all store features.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 32),
              if (_isProcessing)
                const CircularProgressIndicator(color: Colors.green)
              else
                ElevatedButton(
                  onPressed: _completeConversion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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

      // Convert user to store account
      await DatabaseService().convertUserToVetOrStore(
        userId: user.id,
        accountType: 'store',
        firstName: widget.firstName,
        lastName: widget.lastName,
        businessName: widget.storeName,
        businessLocation: widget.storeLocation,
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
            content: Text('Welcome, ${widget.firstName}! Your store account is now active.'),
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
      print('Error completing store conversion: $e');
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
          borderSide: const BorderSide(color: Color(0xFF28a745)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
} 