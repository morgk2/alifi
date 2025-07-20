import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addProductToFirestore() async {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  try {
    await _db.collection('aliexpresslistings').add({
      'title': 'Pet Food Spoon Cup Measuring Scoop Sealing Clip',
      'description': 'Pet food measuring cup with built-in sealing clip. Great for keeping food fresh and measuring exact portions. Made of food-grade plastic.',
      'price': 4.76,
      'originalPrice': 4.88,
      'currency': 'USD',
      'photos': [
        'https://ae-pic-a1.aliexpress-media.com/kf/Sbb4c5632fbdd495fba7ee8b4c8f0c203a.jpg_960x960q75.jpg_.avif',
        'https://ae-pic-a1.aliexpress-media.com/kf/S810011ee3aa74ae981f1613b00186819T.jpg_960x960q75.jpg_.avif',
        'https://ae-pic-a1.aliexpress-media.com/kf/S49e11761089c4e86bb762141c45b290dJ.jpg_960x960q75.jpg_.avif'
      ],
      'affiliateUrl': 'https://s.click.aliexpress.com/e/_oD0EST0',
      'category': 'Food',  // Changed to match our category system
      'rating': 4.7,
      'orders': 6300,
      'isFreeShipping': false,
      'shippingTime': '15-30',
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    });
    print('Product added successfully!');
  } catch (e) {
    print('Error adding product: $e');
  }
}

void main() async {
  try {
    await addProductToFirestore();
    print('Script completed');
  } catch (e) {
    print('Script error: $e');
  }
} 