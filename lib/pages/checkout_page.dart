import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/store_product.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/currency_service.dart';
import '../services/navigation_service.dart';
import '../widgets/spinning_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'address_management_page.dart';
import 'payment_page.dart';

class CheckoutPage extends StatefulWidget {
  final StoreProduct product;

  const CheckoutPage({
    super.key,
    required this.product,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  
  String? _selectedWilaya;
  bool _isLoading = false;
  bool _hasAddresses = false;
  List<Map<String, dynamic>> _addresses = [];
  Map<String, dynamic>? _selectedAddress;
  int _quantity = 1;
  
  final List<String> _wilayas = [
    'Adrar', 'Chlef', 'Laghouat', 'Oum El Bouaghi', 'Batna', 'Béjaïa', 'Biskra', 'Béchar', 'Blida', 'Bouira',
    'Tamanrasset', 'Tébessa', 'Tlemcen', 'Tiaret', 'Tizi Ouzou', 'Algiers', 'Djelfa', 'Jijel', 'Sétif', 'Saïda',
    'Skikda', 'Sidi Bel Abbès', 'Annaba', 'Guelma', 'Constantine', 'Médéa', 'Mostaganem', 'M\'Sila', 'Mascara', 'Ouargla',
    'Oran', 'El Bayadh', 'Illizi', 'Bordj Bou Arréridj', 'Boumerdès', 'El Tarf', 'Tindouf', 'Tissemsilt', 'El Oued', 'Khenchela',
    'Souk Ahras', 'Tipaza', 'Mila', 'Aïn Defla', 'Naâma', 'Aïn Témouchent', 'Ghardaïa', 'Relizane', 'Timimoun', 'Bordj Badji Mokhtar',
    'Ouled Djellal', 'Béni Abbès', 'In Salah', 'In Guezzam', 'Touggourt', 'Djanet', 'El M\'Ghair', 'El Meniaa'
  ];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _couponController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    
    if (user != null) {
      try {
        final userDoc = await DatabaseService().getUser(user.id);
        if (userDoc != null && userDoc.addresses != null && userDoc.addresses!.isNotEmpty) {
          setState(() {
            _addresses = List<Map<String, dynamic>>.from(userDoc.addresses!);
            _hasAddresses = true;
            _selectedAddress = _addresses.first;
          });
        }
      } catch (e) {
        print('Error loading addresses: $e');
      }
    }
  }

  void _navigateToAddressManagement() async {
    await NavigationService.push(
      context,
      const AddressManagementPage(),
    );
    
    // Always reload addresses when returning from address management
    _loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
          'assets/images/back_icon.png',
          width: 24,
          height: 24,
          color: Colors.black,
        ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info Card
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: widget.product.imageUrls.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.product.imageUrls.first,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image),
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Consumer<CurrencyService>(
                          builder: (context, currencyService, child) {
                            return Text(
                              currencyService.formatProductPrice(widget.product.price, widget.product.currency),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Quantity Controls
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: _quantity > 1 ? () {
                                setState(() {
                                  _quantity--;
                                });
                              } : null,
                              icon: Icon(
                                Icons.remove,
                                color: _quantity > 1 ? Colors.grey[700] : Colors.grey[400],
                                size: 20,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                              icon: Icon(
                                Icons.add,
                                color: Colors.grey[700],
                                size: 20,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                                             Consumer<CurrencyService>(
                         builder: (context, currencyService, child) {
                           // Convert to DZD for display
                           final productPriceInDzd = currencyService.getPaymentAmount(widget.product.price, widget.product.currency);
                           return Text(
                             'Total: ${currencyService.formatProductPrice(_quantity * productPriceInDzd, 'DZD')}',
                             style: const TextStyle(
                               fontSize: 14,
                               fontWeight: FontWeight.w600,
                               color: Colors.green,
                             ),
                           );
                         },
                       ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Delivery Address Section
            Container(
              padding: const EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                                     const SizedBox(height: 16),
                   if (_hasAddresses && _selectedAddress != null) ...[
                     Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(
                           color: Colors.grey[300]!,
                           style: BorderStyle.solid,
                         ),
                       ),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             children: [
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       _selectedAddress!['fullName'],
                                       style: const TextStyle(
                                         fontSize: 16,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                     const SizedBox(height: 4),
                                     Text(
                                       _selectedAddress!['phone'],
                                       style: TextStyle(
                                         fontSize: 14,
                                         color: Colors.grey[600],
                                       ),
                                     ),
                                     const SizedBox(height: 4),
                                     Text(
                                       _selectedAddress!['address'],
                                       style: TextStyle(
                                         fontSize: 14,
                                         color: Colors.grey[600],
                                       ),
                                     ),
                                     const SizedBox(height: 4),
                                     Text(
                                       '${_selectedAddress!['zipCode']}, ${_selectedAddress!['wilaya']}',
                                       style: TextStyle(
                                         fontSize: 14,
                                         color: Colors.grey[600],
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                               if (_addresses.length > 1)
                                 PopupMenuButton<String>(
                                   icon: const Icon(Icons.more_vert),
                                   onSelected: (addressId) {
                                     final selected = _addresses.firstWhere((addr) => addr['id'] == addressId);
                                     setState(() {
                                       _selectedAddress = selected;
                                     });
                                   },
                                   itemBuilder: (context) => _addresses.map((address) {
                                     return PopupMenuItem<String>(
                                       value: address['id'],
                                       child: Text(address['fullName']),
                                     );
                                   }).toList(),
                                 ),
                             ],
                           ),
                         ],
                       ),
                     ),
                     const SizedBox(height: 12),
                     ElevatedButton(
                       onPressed: _navigateToAddressManagement,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.green,
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(8),
                         ),
                       ),
                       child: const Text(
                         'Manage Addresses',
                         style: TextStyle(color: Colors.white),
                       ),
                     ),
                   ] else ...[
                     Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: Colors.grey[100],
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: const Row(
                         children: [
                           Icon(Icons.info_outline, color: Colors.grey),
                           SizedBox(width: 8),
                           Text(
                             'You don\'t have any addresses to ship to',
                             style: TextStyle(color: Colors.grey),
                           ),
                         ],
                       ),
                     ),
                     const SizedBox(height: 12),
                     ElevatedButton(
                       onPressed: _navigateToAddressManagement,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.green,
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(8),
                         ),
                       ),
                       child: const Text(
                         'Add Address',
                         style: TextStyle(color: Colors.white),
                       ),
                     ),
                   ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Coupon Code Section
            Container(
              padding: const EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coupon Code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                                             Expanded(
                         child: TextField(
                           controller: _couponController,
                           decoration: InputDecoration(
                             hintText: 'Enter coupon code',
                             border: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(16),
                               borderSide: BorderSide(color: Colors.grey[300]!),
                             ),
                             enabledBorder: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(16),
                               borderSide: BorderSide(color: Colors.grey[300]!),
                             ),
                             focusedBorder: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(16),
                               borderSide: BorderSide(color: Colors.purple, width: 2),
                             ),
                           ),
                         ),
                       ),
                       const SizedBox(width: 12),
                       SizedBox(
                         height: 56,
                         child: ElevatedButton(
                           onPressed: () {
                             // TODO: Implement coupon validation
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(
                                 content: Text('Coupon functionality coming soon!'),
                               ),
                             );
                           },
                           style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.orange,
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(16),
                             ),
                           ),
                           child: const Text(
                             'Apply',
                             style: TextStyle(color: Colors.white),
                           ),
                         ),
                       ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Order Summary
            Container(
              padding: const EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                                                       Consumer<CurrencyService>(
                    builder: (context, currencyService, child) {
                      // Convert product price to DZD for display since we charge in DZD
                      final productPriceInDzd = currencyService.getPaymentAmount(widget.product.price, widget.product.currency);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal (${_quantity}x)'),
                          Text(
                            currencyService.formatProductPrice(_quantity * productPriceInDzd, 'DZD'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                                     Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text('Shipping'),
                       const Text(
                         'Free',
                         style: TextStyle(
                           color: Colors.green,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 8),
                                       Consumer<CurrencyService>(
                      builder: (context, currencyService, child) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tax'),
                                Text(
                                  currencyService.formatProductPrice(2.0, 'DZD'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('App Fee'),
                                Text(
                                  currencyService.formatProductPrice(470.0, 'DZD'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                   const Divider(),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text(
                         'Total',
                         style: TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                                               Consumer<CurrencyService>(
                          builder: (context, currencyService, child) {
                            // Convert product price to DZD and add app fee
                            final productPriceInDzd = currencyService.getPaymentAmount(widget.product.price, widget.product.currency);
                            final subtotalInDzd = _quantity * productPriceInDzd;
                            final totalWithAppFee = subtotalInDzd + 2.0 + 470.0; // Tax + App fee
                            return Text(
                              currencyService.formatProductPrice(totalWithAppFee, 'DZD'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            );
                          },
                        ),
                     ],
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
             bottomNavigationBar: SafeArea(
         child: Container(
           padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
           child: SizedBox(
             height: 56,
             child: ElevatedButton(
               onPressed: _hasAddresses ? () {
                 // Navigate to payment screen
                 final currencyService = Provider.of<CurrencyService>(context, listen: false);
                 final productPriceInDzd = currencyService.getPaymentAmount(widget.product.price, widget.product.currency);
                 final subtotalInDzd = _quantity * productPriceInDzd;
                 final totalWithAppFee = subtotalInDzd + 2.0 + 470.0; // Tax + App fee
                 
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (context) => PaymentPage(
                       product: widget.product,
                       selectedAddress: _selectedAddress!,
                       subtotal: subtotalInDzd,
                       tax: 2.0,
                       total: totalWithAppFee,
                       quantity: _quantity,
                     ),
                   ),
                 );
               } : null,
               style: ElevatedButton.styleFrom(
                 backgroundColor: _hasAddresses ? Colors.green : Colors.grey,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(28),
                 ),
                 elevation: 0,
               ),
               child: Text(
                 _hasAddresses ? 'Next' : 'Add Address to Continue',
                 style: TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.bold,
                   color: _hasAddresses ? Colors.white : Colors.grey[600],
                 ),
               ),
             ),
           ),
         ),
       ),
    );
  }
} 