# Component Documentation - Alifi Pet Care App

## Table of Contents
1. [Core Widgets](#core-widgets)
2. [Custom Cards](#custom-cards)
3. [Form Components](#form-components)
4. [Navigation Components](#navigation-components)
5. [Utility Widgets](#utility-widgets)
6. [Animation Components](#animation-components)
7. [Loading States](#loading-states)
8. [Error Handling](#error-handling)

## Core Widgets

### AIPetAssistantCard
Interactive AI assistant widget with chat functionality.

**Features:**
- Real-time chat interface with Google Gemini AI
- Multi-language support (detects user's language)
- Message history persistence
- Typing indicators and animations
- Expandable/collapsible interface
- Auto-scroll to latest messages

**Props:**
```dart
class AIPetAssistantCard extends StatefulWidget {
  final VoidCallback onTap;           // Called when card is tapped
  final bool isExpanded;              // Controls expanded state
}
```

**Usage Example:**
```dart
AIPetAssistantCard(
  onTap: () {
    setState(() {
      _isAIAssistantExpanded = !_isAIAssistantExpanded;
    });
  },
  isExpanded: _isAIAssistantExpanded,
)
```

**Key Methods:**
```dart
// Send message to AI
Future<void> _sendMessage(String message)

// Load chat history
void _loadMessages()

// Scroll to bottom of chat
void _scrollToBottom()

// Generate AI response
Future<String> _fetchGeminiReply(String userMessage)
```

### ProductCard
Reusable product display component for marketplace.

**Features:**
- Product image with caching and placeholders
- Price display with discount calculations
- Rating and review count
- Seller information
- Quick action buttons
- Responsive design

**Props:**
```dart
class ProductCard extends StatelessWidget {
  final MarketplaceProduct product;   // Product data
  final VoidCallback? onTap;          // Tap handler
  final VoidCallback? onFavorite;     // Favorite action
  final bool showActions;             // Show action buttons
}
```

**Usage Example:**
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
  onFavorite: () {
    // Handle favorite action
  },
  showActions: true,
)
```

### LostPetCard
Display component for lost pet alerts.

**Features:**
- Pet image with placeholder
- Lost pet information (name, breed, color)
- Location and contact details
- Time since lost
- Action buttons (contact, share)
- Distance calculation

**Props:**
```dart
class LostPetCard extends StatelessWidget {
  final LostPet lostPet;              // Lost pet data
  final LatLng? userLocation;         // User's current location
  final VoidCallback? onContact;      // Contact action
  final VoidCallback? onShare;        // Share action
}
```

**Usage Example:**
```dart
LostPetCard(
  lostPet: lostPet,
  userLocation: _userLocation,
  onContact: () {
    // Handle contact action
  },
  onShare: () {
    // Handle share action
  },
)
```

### FundraisingCard
Display component for fundraising campaigns.

**Features:**
- Campaign image and title
- Progress bar with percentage
- Amount raised vs. goal
- Time remaining
- Donation button
- Campaign description

**Props:**
```dart
class FundraisingCard extends StatelessWidget {
  final Fundraising fundraising;      // Fundraising data
  final VoidCallback? onDonate;       // Donation action
  final VoidCallback? onTap;          // Tap to view details
}
```

**Usage Example:**
```dart
FundraisingCard(
  fundraising: fundraising,
  onDonate: () {
    // Handle donation
  },
  onTap: () {
    // Navigate to details
  },
)
```

## Custom Cards

### SellerDashboardCard
Dashboard widget for sellers showing statistics.

**Features:**
- Sales statistics (revenue, orders, products)
- Chart visualization
- Recent activity
- Quick actions
- Performance metrics

**Props:**
```dart
class SellerDashboardCard extends StatelessWidget {
  final Map<String, dynamic> stats;   // Sales statistics
  final List<Map<String, dynamic>> recentActivity; // Recent orders/activity
  final VoidCallback? onViewOrders;   // View orders action
  final VoidCallback? onAddProduct;   // Add product action
}
```

### NotificationCard
Display component for notifications.

**Features:**
- Notification icon based on type
- Title and message
- Timestamp with relative time
- Action buttons
- Read/unread status

**Props:**
```dart
class NotificationCard extends StatelessWidget {
  final Notification notification;    // Notification data
  final VoidCallback? onTap;          // Tap handler
  final VoidCallback? onDismiss;      // Dismiss action
  final bool showActions;             // Show action buttons
}
```

### GiftNotificationBanner
Banner component for gift notifications.

**Features:**
- Animated banner display
- Gift information
- Accept/decline actions
- Auto-dismiss timer
- Custom animations

**Props:**
```dart
class GiftNotificationBanner extends StatefulWidget {
  final Gift gift;                    // Gift data
  final VoidCallback? onAccept;       // Accept gift action
  final VoidCallback? onDecline;      // Decline gift action
  final Duration autoDismissDuration; // Auto-dismiss duration
}
```

## Form Components

### ImagePickerWidget
Custom image picker with preview and upload.

**Features:**
- Camera and gallery options
- Image preview
- Upload progress indicator
- Image compression
- Multiple image support
- Validation

**Props:**
```dart
class ImagePickerWidget extends StatefulWidget {
  final List<String> currentImages;   // Currently selected images
  final Function(List<String>) onImagesChanged; // Callback when images change
  final int maxImages;                // Maximum number of images
  final bool allowMultiple;           // Allow multiple image selection
  final double maxImageSize;          // Maximum image size in MB
}
```

**Usage Example:**
```dart
ImagePickerWidget(
  currentImages: _selectedImages,
  onImagesChanged: (images) {
    setState(() {
      _selectedImages = images;
    });
  },
  maxImages: 5,
  allowMultiple: true,
  maxImageSize: 5.0,
)
```

### SearchBar
Custom search bar with filters and suggestions.

**Features:**
- Real-time search
- Search suggestions
- Filter options
- Search history
- Voice input support
- Debounced input

**Props:**
```dart
class SearchBar extends StatefulWidget {
  final String? initialQuery;         // Initial search query
  final Function(String) onSearch;    // Search callback
  final List<String>? suggestions;    // Search suggestions
  final List<String>? filters;        // Available filters
  final bool showFilters;             // Show filter options
  final bool enableVoice;             // Enable voice input
}
```

### CategorySelector
Category selection widget with icons.

**Features:**
- Grid layout of categories
- Category icons
- Selection state
- Multi-select support
- Custom styling

**Props:**
```dart
class CategorySelector extends StatelessWidget {
  final List<Map<String, dynamic>> categories; // Available categories
  final String? selectedCategory;     // Currently selected category
  final Function(String) onCategorySelected; // Category selection callback
  final bool allowMultiSelect;        // Allow multiple selections
}
```

## Navigation Components

### BottomNavigationBar
Custom bottom navigation with animations.

**Features:**
- Smooth page transitions
- Badge notifications
- Custom icons
- Active state indicators
- Haptic feedback

**Props:**
```dart
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;             // Current selected index
  final Function(int) onTap;          // Tab selection callback
  final List<BottomNavigationBarItem> items; // Navigation items
  final Map<int, int> badgeCounts;    // Badge counts for items
}
```

### AppBar
Custom app bar with search and actions.

**Features:**
- Search integration
- Action buttons
- User avatar
- Notification badge
- Back button handling
- Custom styling

**Props:**
```dart
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;                 // App bar title
  final List<Widget>? actions;        // Action buttons
  final bool showSearch;              // Show search bar
  final Function(String)? onSearch;   // Search callback
  final Widget? leading;              // Leading widget
  final bool automaticallyImplyLeading; // Show back button
}
```

### Drawer
Custom navigation drawer.

**Features:**
- User profile section
- Navigation menu
- Settings options
- Logout functionality
- Custom styling

**Props:**
```dart
class CustomDrawer extends StatelessWidget {
  final User? currentUser;            // Current user data
  final VoidCallback? onProfileTap;   // Profile tap handler
  final VoidCallback? onSettingsTap;  // Settings tap handler
  final VoidCallback? onLogout;       // Logout handler
}
```

## Utility Widgets

### PlaceholderImage
Placeholder image widget with loading states.

**Features:**
- Loading spinner
- Error state
- Retry functionality
- Custom placeholder
- Fade-in animation

**Props:**
```dart
class PlaceholderImage extends StatelessWidget {
  final String? imageUrl;             // Image URL
  final double width;                 // Image width
  final double height;                // Image height
  final BoxFit fit;                   // Image fit
  final Widget? placeholder;          // Custom placeholder
  final VoidCallback? onError;        // Error callback
}
```

### SpinningLoader
Custom loading spinner.

**Features:**
- Customizable animation
- Size options
- Color customization
- Smooth rotation
- Performance optimized

**Props:**
```dart
class SpinningLoader extends StatelessWidget {
  final double size;                  // Loader size
  final Color? color;                 // Loader color
  final Duration duration;            // Animation duration
  final bool isAnimating;             // Animation state
}
```

### TypingIndicator
Typing indicator for chat interfaces.

**Features:**
- Animated dots
- Customizable timing
- Smooth animations
- Chat bubble style
- Auto-start/stop

**Props:**
```dart
class TypingIndicator extends StatefulWidget {
  final bool isTyping;                // Typing state
  final Duration animationDuration;   // Animation duration
  final Color? color;                 // Indicator color
  final double size;                  // Dot size
}
```

### ScrollableFadeContainer
Container with fade effects on scroll.

**Features:**
- Fade in/out on scroll
- Customizable thresholds
- Smooth animations
- Performance optimized
- Scroll direction detection

**Props:**
```dart
class ScrollableFadeContainer extends StatefulWidget {
  final Widget child;                 // Child widget
  final double fadeThreshold;         // Fade threshold
  final Duration animationDuration;   // Animation duration
  final bool fadeIn;                  // Enable fade in
  final bool fadeOut;                 // Enable fade out
}
```

## Animation Components

### AnimatedCounter
Animated number counter.

**Features:**
- Smooth number transitions
- Customizable duration
- Format options
- Prefix/suffix support
- Curved animations

**Props:**
```dart
class AnimatedCounter extends StatefulWidget {
  final int value;                    // Target value
  final Duration duration;            // Animation duration
  final Curve curve;                  // Animation curve
  final TextStyle? style;             // Text style
  final String? prefix;               // Number prefix
  final String? suffix;               // Number suffix
}
```

### FadeInWidget
Widget with fade-in animation.

**Features:**
- Staggered animations
- Custom delays
- Multiple children
- Performance optimized
- Auto-trigger

**Props:**
```dart
class FadeInWidget extends StatefulWidget {
  final Widget child;                 // Child widget
  final Duration duration;            // Animation duration
  final Duration delay;               // Animation delay
  final Curve curve;                  // Animation curve
  final bool autoTrigger;             // Auto-start animation
}
```

### SlideInWidget
Widget with slide-in animation.

**Features:**
- Multiple slide directions
- Customizable distance
- Staggered animations
- Performance optimized
- Auto-trigger

**Props:**
```dart
class SlideInWidget extends StatefulWidget {
  final Widget child;                 // Child widget
  final SlideDirection direction;     // Slide direction
  final double distance;              // Slide distance
  final Duration duration;            // Animation duration
  final Curve curve;                  // Animation curve
}
```

## Loading States

### SkeletonLoader
Skeleton loading animation.

**Features:**
- Multiple skeleton types
- Customizable styling
- Shimmer effect
- Responsive design
- Performance optimized

**Props:**
```dart
class SkeletonLoader extends StatelessWidget {
  final SkeletonType type;            // Skeleton type
  final double width;                 // Width
  final double height;                // Height
  final Color? color;                 // Skeleton color
  final Duration animationDuration;   // Animation duration
}
```

### ShimmerEffect
Shimmer loading effect.

**Features:**
- Smooth shimmer animation
- Customizable colors
- Performance optimized
- Reusable component
- Custom shapes

**Props:**
```dart
class ShimmerEffect extends StatefulWidget {
  final Widget child;                 // Child widget
  final Color baseColor;              // Base color
  final Color highlightColor;         // Highlight color
  final Duration duration;            // Animation duration
  final bool enabled;                 // Enable/disable effect
}
```

### LoadingOverlay
Full-screen loading overlay.

**Features:**
- Full-screen coverage
- Custom loading widget
- Backdrop blur
- Dismissible option
- Custom styling

**Props:**
```dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;               // Loading state
  final Widget? loadingWidget;        // Custom loading widget
  final bool dismissible;             // Allow dismissal
  final Color? backgroundColor;       // Background color
  final VoidCallback? onDismiss;      // Dismiss callback
}
```

## Error Handling

### ErrorWidget
Custom error display widget.

**Features:**
- Error message display
- Retry functionality
- Custom error types
- User-friendly messages
- Action buttons

**Props:**
```dart
class ErrorWidget extends StatelessWidget {
  final String message;               // Error message
  final String? title;                // Error title
  final VoidCallback? onRetry;        // Retry callback
  final ErrorType type;               // Error type
  final Widget? icon;                 // Custom error icon
}
```

### RetryButton
Retry button with loading state.

**Features:**
- Loading state
- Custom styling
- Retry count
- Cooldown period
- Error handling

**Props:**
```dart
class RetryButton extends StatefulWidget {
  final VoidCallback onRetry;         // Retry callback
  final String text;                  // Button text
  final bool isLoading;               // Loading state
  final int maxRetries;               // Maximum retry attempts
  final Duration cooldown;            // Cooldown period
}
```

### EmptyStateWidget
Empty state display widget.

**Features:**
- Custom illustrations
- Action buttons
- Customizable messages
- Multiple empty states
- Responsive design

**Props:**
```dart
class EmptyStateWidget extends StatelessWidget {
  final String title;                 // Empty state title
  final String message;               // Empty state message
  final Widget? illustration;         // Custom illustration
  final VoidCallback? onAction;       // Action callback
  final String? actionText;           // Action button text
}
```

## Component Usage Guidelines

### Best Practices

1. **Consistent Styling**
   - Use theme colors and text styles
   - Maintain consistent spacing
   - Follow design system guidelines

2. **Performance Optimization**
   - Use const constructors where possible
   - Implement proper disposal
   - Optimize rebuilds with ValueNotifier

3. **Accessibility**
   - Add semantic labels
   - Support screen readers
   - Provide alternative text for images

4. **Error Handling**
   - Graceful error states
   - User-friendly error messages
   - Retry mechanisms

5. **Responsive Design**
   - Adapt to different screen sizes
   - Handle orientation changes
   - Test on multiple devices

### Component Testing

```dart
// Widget test example
testWidgets('ProductCard displays product information', (WidgetTester tester) async {
  final product = MarketplaceProduct(
    id: 'test_id',
    name: 'Test Product',
    price: 29.99,
    imageUrl: 'https://example.com/image.jpg',
    sellerId: 'seller_id',
    category: 'Food',
    description: 'Test description',
    createdAt: DateTime.now(),
    isActive: true,
  );

  await tester.pumpWidget(
    MaterialApp(
      home: ProductCard(
        product: product,
        onTap: () {},
      ),
    ),
  );

  expect(find.text('Test Product'), findsOneWidget);
  expect(find.text('\$29.99'), findsOneWidget);
});
```

### Component Documentation Template

```dart
/// [ComponentName] - Brief description
/// 
/// A widget that provides [main functionality].
/// 
/// ## Features
/// - Feature 1
/// - Feature 2
/// - Feature 3
/// 
/// ## Usage
/// ```dart
/// ComponentName(
///   property1: value1,
///   property2: value2,
///   onCallback: () {
///     // Handle callback
///   },
/// )
/// ```
/// 
/// ## Props
/// - `property1` (Type): Description
/// - `property2` (Type): Description
/// - `onCallback` (Function): Description
class ComponentName extends StatelessWidget {
  final Type property1;
  final Type property2;
  final VoidCallback? onCallback;

  const ComponentName({
    super.key,
    required this.property1,
    this.property2,
    this.onCallback,
  });

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

This comprehensive component documentation provides detailed information about all UI components, their features, props, usage examples, and best practices for the Alifi pet care app.