# Alifi - Pet Care App Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Core Features](#core-features)
4. [Models](#models)
5. [Services](#services)
6. [Pages](#pages)
7. [Widgets](#widgets)
8. [Configuration](#configuration)
9. [API Integration](#api-integration)
10. [Performance Optimizations](#performance-optimizations)
11. [Usage Examples](#usage-examples)
12. [Development Guide](#development-guide)

## Overview

Alifi is a comprehensive Flutter-based pet care application that provides a complete ecosystem for pet owners, veterinarians, and pet product sellers. The app features pet management, health tracking, marketplace functionality, AI-powered assistance, and social features.

### Key Features
- **Pet Management**: Complete pet profiles with health records
- **AI Assistant**: Virtual pet assistant powered by Google Gemini
- **Marketplace**: E-commerce platform for pet products
- **Veterinary Services**: Vet location finder and consultations
- **Social Features**: Pet adoption, lost pet alerts, fundraising
- **Multi-language Support**: English, Arabic, French
- **Real-time Chat**: Communication between users and sellers

## Architecture

### Technology Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Auth, Storage)
- **Additional Services**: Supabase (Storage), Google Maps API, Google Gemini AI
- **State Management**: Provider pattern with ValueNotifier
- **Localization**: Flutter Intl

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── services/                 # Business logic and API calls
├── pages/                    # Screen implementations
├── widgets/                  # Reusable UI components
├── config/                   # Configuration files
├── utils/                    # Utility functions
├── dialogs/                  # Modal dialogs
├── l10n/                     # Localization files
└── icons.dart               # Custom icons
```

## Core Features

### 1. Authentication System
- **Multi-provider Authentication**: Google, Apple, Facebook, Email/Password
- **Guest Mode**: Limited functionality without registration
- **Account Types**: Normal users, veterinarians, sellers, admins
- **Profile Management**: Complete user profiles with verification

### 2. Pet Management
- **Pet Profiles**: Comprehensive pet information storage
- **Health Records**: Medical history, vaccinations, illnesses
- **Dietary Information**: Food preferences and restrictions
- **Photo Management**: Multiple images per pet
- **Adoption System**: Pet adoption listings and management

### 3. AI Assistant (Lufi)
- **Virtual Pet Assistant**: Powered by Google Gemini 2.0 Flash
- **Multi-language Support**: Detects and responds in user's language
- **Pet Care Advice**: Practical guidance for pet owners
- **Real-time Chat**: Interactive conversation interface
- **Context Awareness**: Remembers conversation history

### 4. Marketplace
- **Product Catalog**: Categorized pet products
- **Seller Dashboard**: Store management for sellers
- **Order Management**: Complete order lifecycle
- **Payment Integration**: Multiple payment methods
- **Product Reviews**: Rating and review system

### 5. Location Services
- **Vet Finder**: Locate nearby veterinary clinics
- **Store Locator**: Find pet stores in the area
- **Map Integration**: Google Maps integration
- **Distance Calculation**: Proximity-based recommendations

### 6. Social Features
- **Lost Pet Alerts**: Community-based pet finding
- **Fundraising**: Pet-related fundraising campaigns
- **Leaderboard**: Gamification elements
- **User Following**: Social networking features

## Models

### User Model
```dart
class User {
  final String id;
  final String email;
  final String? displayName;
  final String? username;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, bool> linkedAccounts;
  final bool isAdmin;
  final String accountType; // 'normal', 'vet', 'seller', 'admin'
  final bool isVerified;
  final double rating;
  final int totalOrders;
  final List<String> pets;
  final List<String> followers;
  final List<String> following;
  final LatLng? location;
}
```

**Usage Example:**
```dart
// Create a new user
final user = User(
  id: 'user123',
  email: 'user@example.com',
  displayName: 'John Doe',
  accountType: 'normal',
  createdAt: DateTime.now(),
  lastLoginAt: DateTime.now(),
  linkedAccounts: {'google': true},
);

// Convert to Firestore
final userData = user.toFirestore();

// Create from Firestore
final userFromFirestore = User.fromFirestore(documentSnapshot);
```

### Pet Model
```dart
class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final String color;
  final int age;
  final String gender;
  final List<String> imageUrls;
  final String ownerId;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final Map<String, dynamic> medicalInfo;
  final Map<String, dynamic> dietaryInfo;
  final List<String> tags;
  final bool isActive;
  final bool isForAdoption;
  final double? weight;
  final String? microchipId;
  final String? description;
  final List<Map<String, dynamic>>? vaccines;
  final List<Map<String, dynamic>>? illnesses;
}
```

**Usage Example:**
```dart
// Create a new pet
final pet = Pet(
  id: 'pet123',
  name: 'Buddy',
  species: 'Dog',
  breed: 'Golden Retriever',
  color: 'Golden',
  age: 3,
  gender: 'Male',
  imageUrls: ['https://example.com/buddy.jpg'],
  ownerId: 'user123',
  createdAt: DateTime.now(),
  lastUpdatedAt: DateTime.now(),
  medicalInfo: {'vaccinations': ['rabies', 'distemper']},
  dietaryInfo: {'allergies': ['chicken']},
  tags: ['friendly', 'active'],
  isActive: true,
  weight: 25.5,
);

// Update pet information
final updatedPet = pet.copyWith(
  age: 4,
  weight: 26.0,
  medicalInfo: {...pet.medicalInfo, 'lastCheckup': '2024-01-15'},
);
```

### Other Models
- **LostPet**: Lost pet alerts with location and contact information
- **MarketplaceProduct**: Product information for marketplace
- **Order**: Order management with status tracking
- **ChatMessage**: Real-time messaging system
- **Notification**: Push notification management
- **Gift**: Gift system for social features

## Services

### AuthService
Handles all authentication-related operations.

**Key Methods:**
```dart
class AuthService extends ChangeNotifier {
  // Sign in with Google
  Future<UserCredential?> signInWithGoogle();
  
  // Sign in with Apple
  Future<UserCredential?> signInWithApple();
  
  // Sign in with Facebook
  Future<UserCredential?> signInWithFacebook();
  
  // Email/password authentication
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password);
  
  // Sign out
  Future<void> signOut();
  
  // Guest mode
  Future<void> enterGuestMode();
  
  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> updates);
}
```

**Usage Example:**
```dart
final authService = context.read<AuthService>();

// Sign in with Google
try {
  final userCredential = await authService.signInWithGoogle();
  if (userCredential != null) {
    print('Successfully signed in: ${userCredential.user?.email}');
  }
} catch (e) {
  print('Sign in failed: $e');
}

// Listen to auth state changes
authService.addListener(() {
  if (authService.isAuthenticated) {
    print('User is authenticated');
  } else {
    print('User is not authenticated');
  }
});
```

### DatabaseService
Manages all Firestore database operations.

**Key Methods:**
```dart
class DatabaseService {
  // User operations
  Future<void> createUser(User user);
  Future<User?> getUser(String userId);
  Future<void> updateUser(String userId, Map<String, dynamic> updates);
  
  // Pet operations
  Future<void> createPet(Pet pet);
  Future<List<Pet>> getUserPets(String userId);
  Future<void> updatePet(String petId, Map<String, dynamic> updates);
  Future<void> deletePet(String petId);
  
  // Marketplace operations
  Future<List<MarketplaceProduct>> getProducts({
    String? category,
    String? searchQuery,
    String? sortBy,
  });
  Future<void> createProduct(MarketplaceProduct product);
  
  // Location operations
  Future<List<Location>> getNearbyVets(LatLng location, double radius);
  Future<List<Location>> getNearbyStores(LatLng location, double radius);
  
  // Chat operations
  Future<void> sendMessage(ChatMessage message);
  Stream<List<ChatMessage>> getChatMessages(String chatId);
}
```

**Usage Example:**
```dart
final databaseService = DatabaseService();

// Get user's pets
final pets = await databaseService.getUserPets('user123');
print('User has ${pets.length} pets');

// Search for products
final products = await databaseService.getProducts(
  category: 'Food',
  searchQuery: 'dog food',
  sortBy: 'price_low',
);

// Listen to real-time chat messages
databaseService.getChatMessages('chat123').listen((messages) {
  print('New messages: ${messages.length}');
});
```

### Other Services
- **StorageService**: File upload and management with Supabase
- **LocationService**: GPS and location-based features
- **NotificationService**: Push notification management
- **ChatService**: Real-time messaging functionality
- **PlacesService**: Google Places API integration

## Pages

### HomePage
Main dashboard with personalized content and AI assistant.

**Key Features:**
- Personalized pet recommendations
- AI assistant integration
- Recent activities feed
- Quick access to main features
- Location-based content

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => HomePage(
      onNavigateToMap: () => Navigator.pushNamed(context, '/map'),
      onAIAssistantExpanded: (expanded) {
        // Handle AI assistant expansion
      },
    ),
  ),
);
```

### MyPetsPage
Comprehensive pet management interface.

**Key Features:**
- Pet profile management
- Health record tracking
- Photo gallery
- Medical history
- Dietary information

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MyPetsPage(),
  ),
);
```

### MarketplacePage
E-commerce platform for pet products.

**Key Features:**
- Product browsing and search
- Category filtering
- Price sorting
- Seller information
- Product reviews

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MarketplacePage(),
  ),
);
```

### MapPage
Location-based services and vet/store finder.

**Key Features:**
- Interactive map interface
- Vet and store locations
- Distance calculation
- Navigation integration
- Location-based recommendations

### Other Pages
- **ProfilePage**: User profile management
- **SettingsPage**: App configuration
- **PetHealthPage**: Health tracking interface
- **StorePages**: Seller-specific interfaces
- **AdminPages**: Administrative functions

## Widgets

### AIPetAssistantCard
Interactive AI assistant widget with chat functionality.

**Features:**
- Real-time chat interface
- Multi-language support
- Message history
- Typing indicators
- Expandable interface

**Usage:**
```dart
AIPetAssistantCard(
  onTap: () {
    // Handle card tap
  },
  isExpanded: _isExpanded,
)
```

### ProductCard
Reusable product display component.

**Features:**
- Product image display
- Price and rating
- Seller information
- Quick actions
- Cached image loading

**Usage:**
```dart
ProductCard(
  product: marketplaceProduct,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(product: product),
      ),
    );
  },
)
```

### Other Widgets
- **LostPetCard**: Lost pet alert display
- **FundraisingCard**: Fundraising campaign display
- **NotificationCard**: Notification display
- **SellerDashboardCard**: Seller statistics
- **SalesChartWidget**: Analytics visualization

## Configuration

### Firebase Configuration
```dart
// firebase_options.dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Platform-specific Firebase configuration
  }
}
```

### Supabase Configuration
```dart
// config/supabase_config.dart
class SupabaseConfig {
  static const String projectUrl = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### Google Maps Configuration
```dart
// Android: android/app/src/main/AndroidManifest.xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

### Localization Configuration
```dart
// l10n/app_localizations.dart
class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate =
    _AppLocalizationsDelegate();
  
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
}
```

## API Integration

### Google Gemini AI
```dart
Future<String> _fetchGeminiReply(String userMessage) async {
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey');
  
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": "You are a virtual pet assistant..."},
            {"text": userMessage}
          ]
        }
      ]
    }),
  );
  
  final data = jsonDecode(response.body);
  return data['candidates'][0]['content']['parts'][0]['text'];
}
```

### Google Places API
```dart
Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey'
  );
  
  final response = await http.get(url);
  final data = jsonDecode(response.body);
  
  if (data['status'] == 'OK') {
    return data['result'];
  }
  return null;
}
```

### Supabase Storage
```dart
Future<String?> uploadImage(File imageFile) async {
  try {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final response = await _supabase.storage
      .from('pet-images')
      .upload(fileName, imageFile);
    
    return _supabase.storage
      .from('pet-images')
      .getPublicUrl(fileName);
  } catch (e) {
    print('Error uploading image: $e');
    return null;
  }
}
```

## Performance Optimizations

### 1. Image Caching
- **CachedNetworkImage**: Efficient image loading and caching
- **Placeholder Images**: Loading states for better UX
- **Image Compression**: Automatic image optimization

### 2. State Management
- **ValueNotifier**: Localized state updates
- **Provider Pattern**: Efficient state distribution
- **RepaintBoundary**: Optimized widget rendering

### 3. List Optimization
- **ListView.builder**: Efficient list rendering
- **RepaintBoundary**: Isolated widget repaints
- **Const Constructors**: Reduced widget rebuilds

### 4. Memory Management
- **Proper Disposal**: Resource cleanup
- **Lazy Loading**: On-demand data loading
- **Debouncing**: Reduced API calls

## Usage Examples

### Creating a New Pet Profile
```dart
Future<void> createPetProfile() async {
  final databaseService = DatabaseService();
  final authService = context.read<AuthService>();
  
  final pet = Pet(
    id: const Uuid().v4(),
    name: 'Buddy',
    species: 'Dog',
    breed: 'Golden Retriever',
    color: 'Golden',
    age: 3,
    gender: 'Male',
    imageUrls: [],
    ownerId: authService.currentUser!.id,
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    medicalInfo: {},
    dietaryInfo: {},
    tags: [],
    isActive: true,
  );
  
  await databaseService.createPet(pet);
  print('Pet profile created successfully');
}
```

### Searching for Products
```dart
Future<void> searchProducts(String query) async {
  final databaseService = DatabaseService();
  
  final products = await databaseService.getProducts(
    searchQuery: query,
    category: 'Food',
    sortBy: 'price_low',
  );
  
  setState(() {
    _searchResults = products;
  });
}
```

### Using the AI Assistant
```dart
void sendMessageToAI(String message) async {
  setState(() {
    _isLoading = true;
  });
  
  try {
    final response = await _fetchGeminiReply(message);
    setState(() {
      _messages.add(ChatMessage(
        id: const Uuid().v4(),
        senderId: 'ai',
        content: response,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    print('Error getting AI response: $e');
  }
}
```

### Location-Based Services
```dart
Future<void> findNearbyVets() async {
  final locationService = LocationService();
  final databaseService = DatabaseService();
  
  // Get current location
  final position = await locationService.getCurrentPosition();
  final userLocation = LatLng(position.latitude, position.longitude);
  
  // Find nearby vets
  final vets = await databaseService.getNearbyVets(userLocation, 10.0);
  
  setState(() {
    _nearbyVets = vets;
  });
}
```

## Development Guide

### Setting Up the Project
1. **Clone the repository**
2. **Install dependencies**: `flutter pub get`
3. **Configure Firebase**: Add your Firebase configuration
4. **Configure Supabase**: Add your Supabase credentials
5. **Set up API keys**: Google Maps, Gemini AI
6. **Run the app**: `flutter run`

### Code Style Guidelines
- Use **const constructors** where possible
- Implement **proper error handling**
- Add **comprehensive documentation**
- Follow **Flutter best practices**
- Use **meaningful variable names**

### Testing
```dart
// Unit tests for services
test('should create user successfully', () async {
  final authService = AuthService();
  final result = await authService.createUser(testUser);
  expect(result, isNotNull);
});

// Widget tests
testWidgets('should display pet information', (WidgetTester tester) async {
  await tester.pumpWidget(MyPetsPage());
  expect(find.text('My Pets'), findsOneWidget);
});
```

### Deployment
1. **Build for production**: `flutter build apk --release`
2. **Test thoroughly** on multiple devices
3. **Update version** in pubspec.yaml
4. **Deploy to app stores**

### Performance Monitoring
- Monitor **app startup time**
- Track **memory usage**
- Measure **API response times**
- Analyze **user engagement metrics**

This comprehensive documentation provides a complete overview of the Alifi pet care app, including all features, components, and usage instructions. The app is designed to be scalable, maintainable, and user-friendly while providing a rich set of features for pet owners and service providers.