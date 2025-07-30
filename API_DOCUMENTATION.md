# API Documentation - Alifi Pet Care App

## Table of Contents
1. [Firebase Services](#firebase-services)
2. [Supabase Integration](#supabase-integration)
3. [Google APIs](#google-apis)
4. [External Services](#external-services)
5. [Authentication APIs](#authentication-apis)
6. [Database Operations](#database-operations)
7. [File Storage](#file-storage)
8. [Push Notifications](#push-notifications)

## Firebase Services

### Firebase Authentication

#### Google Sign-In
```dart
Future<UserCredential?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    return await _auth.signInWithCredential(credential);
  } catch (e) {
    print('Google sign-in error: $e');
    return null;
  }
}
```

**Parameters:** None
**Returns:** `UserCredential?` - Firebase user credential or null if failed
**Error Handling:** Catches and logs authentication errors

#### Apple Sign-In
```dart
Future<UserCredential?> signInWithApple() async {
  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: credential.identityToken,
      accessToken: credential.authorizationCode,
    );
    
    return await _auth.signInWithCredential(oauthCredential);
  } catch (e) {
    print('Apple sign-in error: $e');
    return null;
  }
}
```

**Parameters:** None
**Returns:** `UserCredential?` - Firebase user credential or null if failed
**Platform:** iOS only

#### Facebook Sign-In
```dart
Future<UserCredential?> signInWithFacebook() async {
  try {
    final LoginResult result = await FacebookAuth.instance.login();
    
    if (result.status == LoginStatus.success) {
      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.token,
      );
      return await _auth.signInWithCredential(credential);
    }
    return null;
  } catch (e) {
    print('Facebook sign-in error: $e');
    return null;
  }
}
```

**Parameters:** None
**Returns:** `UserCredential?` - Firebase user credential or null if failed

### Firestore Database

#### User Operations

**Create User**
```dart
Future<void> createUser(User user) async {
  try {
    await _usersCollection.doc(user.id).set(user.toFirestore());
    print('User created successfully: ${user.id}');
  } catch (e) {
    print('Error creating user: $e');
    rethrow;
  }
}
```

**Get User**
```dart
Future<User?> getUser(String userId) async {
  try {
    final doc = await _usersCollection.doc(userId).get();
    if (doc.exists) {
      return User.fromFirestore(doc);
    }
    return null;
  } catch (e) {
    print('Error getting user: $e');
    return null;
  }
}
```

**Update User**
```dart
Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
  try {
    await _usersCollection.doc(userId).update({
      ...updates,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    });
    print('User updated successfully: $userId');
  } catch (e) {
    print('Error updating user: $e');
    rethrow;
  }
}
```

#### Pet Operations

**Create Pet**
```dart
Future<void> createPet(Pet pet) async {
  try {
    await _petsCollection.doc(pet.id).set(pet.toFirestore());
    
    // Update user's pets list
    await _usersCollection.doc(pet.ownerId).update({
      'pets': FieldValue.arrayUnion([pet.id]),
    });
    
    print('Pet created successfully: ${pet.id}');
  } catch (e) {
    print('Error creating pet: $e');
    rethrow;
  }
}
```

**Get User Pets**
```dart
Future<List<Pet>> getUserPets(String userId) async {
  try {
    final querySnapshot = await _petsCollection
        .where('ownerId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => Pet.fromFirestore(doc))
        .toList();
  } catch (e) {
    print('Error getting user pets: $e');
    return [];
  }
}
```

**Update Pet**
```dart
Future<void> updatePet(String petId, Map<String, dynamic> updates) async {
  try {
    await _petsCollection.doc(petId).update({
      ...updates,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    });
    print('Pet updated successfully: $petId');
  } catch (e) {
    print('Error updating pet: $e');
    rethrow;
  }
}
```

#### Marketplace Operations

**Get Products**
```dart
Future<List<MarketplaceProduct>> getProducts({
  String? category,
  String? searchQuery,
  String? sortBy,
  int limit = 20,
}) async {
  try {
    Query query = _storeProductsCollection.where('isActive', isEqualTo: true);
    
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.where('searchTokens', arrayContains: searchQuery.toLowerCase());
    }
    
    // Apply sorting
    switch (sortBy) {
      case 'price_low':
        query = query.orderBy('price', descending: false);
        break;
      case 'price_high':
        query = query.orderBy('price', descending: true);
        break;
      case 'newest':
        query = query.orderBy('createdAt', descending: true);
        break;
      case 'orders':
      default:
        query = query.orderBy('totalOrders', descending: true);
        break;
    }
    
    query = query.limit(limit);
    
    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => MarketplaceProduct.fromFirestore(doc))
        .toList();
  } catch (e) {
    print('Error getting products: $e');
    return [];
  }
}
```

**Create Product**
```dart
Future<void> createProduct(MarketplaceProduct product) async {
  try {
    await _storeProductsCollection.doc(product.id).set(product.toFirestore());
    
    // Update seller's products list
    await _usersCollection.doc(product.sellerId).update({
      'products': FieldValue.arrayUnion([product.id]),
    });
    
    print('Product created successfully: ${product.id}');
  } catch (e) {
    print('Error creating product: $e');
    rethrow;
  }
}
```

#### Chat Operations

**Send Message**
```dart
Future<void> sendMessage(ChatMessage message) async {
  try {
    await _chatMessagesCollection.doc(message.id).set(message.toFirestore());
    
    // Send push notification to recipient
    if (message.senderId != message.recipientId) {
      await NotificationService().sendChatNotification(message);
    }
    
    print('Message sent successfully: ${message.id}');
  } catch (e) {
    print('Error sending message: $e');
    rethrow;
  }
}
```

**Get Chat Messages**
```dart
Stream<List<ChatMessage>> getChatMessages(String chatId) {
  return _chatMessagesCollection
      .where('chatId', isEqualTo: chatId)
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList());
}
```

## Supabase Integration

### Storage Service

**Upload Image**
```dart
Future<String?> uploadImage(File imageFile, String bucket) async {
  try {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    
    await _supabase.storage
        .from(bucket)
        .upload(fileName, imageFile);
    
    final publicUrl = _supabase.storage
        .from(bucket)
        .getPublicUrl(fileName);
    
    print('Image uploaded successfully: $fileName');
    return publicUrl;
  } catch (e) {
    print('Error uploading image: $e');
    return null;
  }
}
```

**Delete Image**
```dart
Future<bool> deleteImage(String fileName, String bucket) async {
  try {
    await _supabase.storage
        .from(bucket)
        .remove([fileName]);
    
    print('Image deleted successfully: $fileName');
    return true;
  } catch (e) {
    print('Error deleting image: $e');
    return false;
  }
}
```

**Get Image URL**
```dart
String getImageUrl(String fileName, String bucket) {
  return _supabase.storage
      .from(bucket)
      .getPublicUrl(fileName);
}
```

### Authentication

**Anonymous Sign-In**
```dart
Future<void> signInAnonymously() async {
  try {
    await _supabase.auth.signInAnonymously();
    print('Supabase anonymous sign-in successful');
  } catch (e) {
    print('Supabase anonymous sign-in error: $e');
  }
}
```

## Google APIs

### Google Gemini AI

**Generate AI Response**
```dart
Future<String> generateAIResponse(String userMessage, String context) async {
  const apiKey = 'YOUR_GEMINI_API_KEY';
  const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  
  try {
    final response = await http.post(
      Uri.parse('$url?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": context},
              {"text": userMessage}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 1024,
        }
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Failed to generate response: ${response.statusCode}');
    }
  } catch (e) {
    print('Error generating AI response: $e');
    rethrow;
  }
}
```

**Parameters:**
- `userMessage` (String): User's input message
- `context` (String): AI assistant context/personality

**Returns:** `String` - AI-generated response
**Error Handling:** Throws exception on API failure

### Google Places API

**Get Place Details**
```dart
Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
  const apiKey = 'YOUR_GOOGLE_PLACES_API_KEY';
  const url = 'https://maps.googleapis.com/maps/api/place/details/json';
  
  try {
    final response = await http.get(
      Uri.parse('$url?place_id=$placeId&key=$apiKey&fields=name,vicinity,opening_hours,rating,formatted_phone_number,website'),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        return data['result'];
      }
    }
    return null;
  } catch (e) {
    print('Error getting place details: $e');
    return null;
  }
}
```

**Search Nearby Places**
```dart
Future<List<Map<String, dynamic>>> searchNearbyPlaces(
  double latitude,
  double longitude,
  String type,
  double radius,
) async {
  const apiKey = 'YOUR_GOOGLE_PLACES_API_KEY';
  const url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  
  try {
    final response = await http.get(
      Uri.parse('$url?location=$latitude,$longitude&radius=$radius&type=$type&key=$apiKey'),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        return List<Map<String, dynamic>>.from(data['results']);
      }
    }
    return [];
  } catch (e) {
    print('Error searching nearby places: $e');
    return [];
  }
}
```

### Google Maps API

**Geocoding**
```dart
Future<LatLng?> geocodeAddress(String address) async {
  const apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  const url = 'https://maps.googleapis.com/maps/api/geocode/json';
  
  try {
    final response = await http.get(
      Uri.parse('$url?address=${Uri.encodeComponent(address)}&key=$apiKey'),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      }
    }
    return null;
  } catch (e) {
    print('Error geocoding address: $e');
    return null;
  }
}
```

**Reverse Geocoding**
```dart
Future<String?> reverseGeocode(LatLng location) async {
  const apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  const url = 'https://maps.googleapis.com/maps/api/geocode/json';
  
  try {
    final response = await http.get(
      Uri.parse('$url?latlng=${location.latitude},${location.longitude}&key=$apiKey'),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address'];
      }
    }
    return null;
  } catch (e) {
    print('Error reverse geocoding: $e');
    return null;
  }
}
```

## External Services

### AliExpress API (Mock)

**Get Product Recommendations**
```dart
Future<List<AliExpressProduct>> getAliExpressProducts({
  String? category,
  String? searchQuery,
  int limit = 10,
}) async {
  // Mock implementation - replace with actual AliExpress API
  await Future.delayed(const Duration(milliseconds: 500));
  
  return List.generate(limit, (index) => AliExpressProduct(
    id: 'aliexpress_$index',
    title: 'Mock Product ${index + 1}',
    price: (10.0 + index * 5.0).toString(),
    originalPrice: (15.0 + index * 5.0).toString(),
    imageUrl: 'https://via.placeholder.com/300x300?text=Product${index + 1}',
    rating: 4.0 + (index % 5) * 0.2,
    reviewCount: 100 + index * 10,
    sellerName: 'Mock Seller ${index + 1}',
    shippingInfo: 'Free shipping',
    category: category ?? 'General',
  ));
}
```

### Payment APIs

**Stripe Payment**
```dart
Future<Map<String, dynamic>> processStripePayment({
  required String amount,
  required String currency,
  required String paymentMethodId,
}) async {
  const apiKey = 'YOUR_STRIPE_SECRET_KEY';
  const url = 'https://api.stripe.com/v1/payment_intents';
  
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': amount,
        'currency': currency,
        'payment_method': paymentMethodId,
        'confirm': 'true',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Payment failed: ${response.statusCode}');
    }
  } catch (e) {
    print('Error processing payment: $e');
    rethrow;
  }
}
```

**PayPal Payment**
```dart
Future<Map<String, dynamic>> processPayPalPayment({
  required String amount,
  required String currency,
  required String orderId,
}) async {
  const clientId = 'YOUR_PAYPAL_CLIENT_ID';
  const clientSecret = 'YOUR_PAYPAL_CLIENT_SECRET';
  const url = 'https://api-m.paypal.com/v2/checkout/orders/$orderId/capture';
  
  try {
    // Get access token first
    final tokenResponse = await http.post(
      Uri.parse('https://api-m.paypal.com/v1/oauth2/token'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );
    
    final tokenData = jsonDecode(tokenResponse.body);
    final accessToken = tokenData['access_token'];
    
    // Capture payment
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('PayPal payment failed: ${response.statusCode}');
    }
  } catch (e) {
    print('Error processing PayPal payment: $e');
    rethrow;
  }
}
```

## Push Notifications

### Firebase Cloud Messaging

**Send Notification**
```dart
Future<void> sendPushNotification({
  required String token,
  required String title,
  required String body,
  Map<String, dynamic>? data,
}) async {
  const serverKey = 'YOUR_FCM_SERVER_KEY';
  const url = 'https://fcm.googleapis.com/fcm/send';
  
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'key=$serverKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'to': token,
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
        },
        'data': data ?? {},
        'priority': 'high',
      }),
    );
    
    if (response.statusCode == 200) {
      print('Push notification sent successfully');
    } else {
      print('Failed to send push notification: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending push notification: $e');
  }
}
```

**Subscribe to Topic**
```dart
Future<void> subscribeToTopic(String topic) async {
  try {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  } catch (e) {
    print('Error subscribing to topic: $e');
  }
}
```

**Unsubscribe from Topic**
```dart
Future<void> unsubscribeFromTopic(String topic) async {
  try {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  } catch (e) {
    print('Error unsubscribing from topic: $e');
  }
}
```

## Error Handling

### API Error Response Format
```dart
class APIError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;
  
  APIError({
    required this.code,
    required this.message,
    this.details,
  });
  
  factory APIError.fromJson(Map<String, dynamic> json) {
    return APIError(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'An unknown error occurred',
      details: json['details'],
    );
  }
}
```

### Error Handling Utility
```dart
class APIErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is APIError) {
      return error.message;
    } else if (error is FirebaseException) {
      return _getFirebaseErrorMessage(error);
    } else if (error is HttpException) {
      return 'Network error: ${error.message}';
    } else {
      return 'An unexpected error occurred';
    }
  }
  
  static String _getFirebaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Access denied. Please check your permissions.';
      case 'not-found':
        return 'The requested resource was not found.';
      case 'already-exists':
        return 'The resource already exists.';
      case 'resource-exhausted':
        return 'Resource limit exceeded. Please try again later.';
      case 'failed-precondition':
        return 'Operation failed due to invalid state.';
      case 'aborted':
        return 'Operation was aborted.';
      case 'out-of-range':
        return 'Operation is out of valid range.';
      case 'unimplemented':
        return 'Operation is not implemented.';
      case 'internal':
        return 'Internal server error. Please try again.';
      case 'unavailable':
        return 'Service is currently unavailable.';
      case 'data-loss':
        return 'Data loss occurred.';
      case 'unauthenticated':
        return 'Authentication required.';
      default:
        return error.message ?? 'An unknown Firebase error occurred.';
    }
  }
}
```

## Rate Limiting and Caching

### API Rate Limiting
```dart
class RateLimiter {
  final Map<String, DateTime> _lastCallTimes = {};
  final Map<String, int> _callCounts = {};
  
  bool canMakeCall(String endpoint, {int maxCallsPerMinute = 60}) {
    final now = DateTime.now();
    final lastCall = _lastCallTimes[endpoint];
    
    if (lastCall == null) {
      _lastCallTimes[endpoint] = now;
      _callCounts[endpoint] = 1;
      return true;
    }
    
    final timeDiff = now.difference(lastCall).inMinutes;
    if (timeDiff >= 1) {
      _lastCallTimes[endpoint] = now;
      _callCounts[endpoint] = 1;
      return true;
    }
    
    final callCount = _callCounts[endpoint] ?? 0;
    if (callCount < maxCallsPerMinute) {
      _callCounts[endpoint] = callCount + 1;
      return true;
    }
    
    return false;
  }
}
```

### Response Caching
```dart
class APICache {
  final Map<String, Map<String, dynamic>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration;
  
  APICache({this.cacheDuration = const Duration(minutes: 5)});
  
  void set(String key, Map<String, dynamic> data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }
  
  Map<String, dynamic>? get(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;
    
    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }
    
    return _cache[key];
  }
  
  void clear() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}
```

This comprehensive API documentation covers all the external services, authentication methods, database operations, and utility functions used in the Alifi pet care app. Each API endpoint includes parameters, return values, error handling, and usage examples.