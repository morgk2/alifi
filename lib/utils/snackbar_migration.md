# SnackBar Migration Guide

## Overview
This project has been updated to use a modern, custom SnackBar implementation instead of Flutter's default SnackBar.

## Custom SnackBar Features

### Design
- ✅ 12px rounded corners
- ✅ Semi-transparent blurred background (Material 3 style)
- ✅ Subtle drop shadow
- ✅ Centered text with larger font size (16px)
- ✅ Custom animations (slide-up + fade in/out)
- ✅ Custom padding (vertical: 12, horizontal: 16)

### Types and Colors
- **Success**: Translucent green background, white text
- **Error**: Translucent red background, white text  
- **Info**: Translucent dark grey background, white text

### Animation
- ✅ Smooth slide-up animation when showing (300ms, easeOutCubic)
- ✅ Smooth slide-down + fade animation when hiding
- ✅ Consistent across iOS and Android

## Usage

### Import
```dart
import '../widgets/custom_snackbar.dart';
```

### Helper Methods

#### Success Messages
```dart
CustomSnackBarHelper.showSuccess(
  context,
  'Operation completed successfully!',
  duration: const Duration(seconds: 3), // optional
);
```

#### Error Messages
```dart
CustomSnackBarHelper.showError(
  context,
  'Something went wrong!',
  duration: const Duration(seconds: 3), // optional
);
```

#### Info Messages
```dart
CustomSnackBarHelper.showInfo(
  context,
  'Information message',
  duration: const Duration(seconds: 3), // optional
);
```

#### With Action Button
```dart
CustomSnackBarHelper.showError(
  context,
  'Failed to save data',
  actionLabel: 'Retry',
  onAction: () {
    // Handle retry action
  },
);
```

## Migration Progress

### ✅ Completed Files
- lib/widgets/custom_snackbar.dart (new implementation)
- lib/pages/settings_page.dart
- lib/pages/map_page.dart
- lib/pages/my_pets_page.dart
- lib/dialogs/appointment_booking_dialog.dart
- lib/pages/notifications_page.dart
- lib/pages/pet_health_page.dart (import added)

### 🟡 Remaining Files
Files that still need manual replacement:
- lib/pages/location_setup_page.dart (3 usages)
- lib/pages/store_signup_page.dart (4 usages)
- lib/pages/vet_signup_page.dart (4 usages)
- lib/pages/subscription_management_page.dart (4 usages)
- lib/pages/home_page.dart (1 usage)
- lib/main.dart (1 usage)
- lib/pages/detailed_vet_dashboard_page.dart (6 usages)
- lib/dialogs/add_pet_dialog.dart (2 usages)
- lib/pages/address_management_page.dart (6 usages)
- lib/pages/checkout_page.dart (1 usage)
- lib/pages/discussion_chat_page.dart (1 usage)
- lib/pages/edit_profile_page.dart (2 usages)
- lib/pages/payment_page.dart (3 usages)
- lib/pages/store_receiver_chat_page.dart (1 usage)
- lib/pages/product_details_page.dart (1 usage)
- lib/pages/store_chat_page.dart (1 usage)
- lib/pages/user_orders_page.dart (8 usages)
- lib/pages/user_profile_page.dart (5 usages)
- lib/pages/vet_chat_page.dart (1 usage)
- lib/pages/vet_schedule_page.dart (3 usages)
- lib/pages/user_search_page.dart (1 usage)
- lib/dialogs/permission_request_dialog.dart (2 usages)
- lib/dialogs/store_products_dialog.dart (3 usages)
- lib/pages/store_orders_tab.dart (2 usages)
- lib/pages/about_page.dart (5 usages)
- lib/pages/appointment_details_page.dart (5 usages)
- lib/widgets/review_dialog.dart (1 usage)
- lib/widgets/today_appointment_widget.dart (1 usage)
- lib/widgets/notification_settings_widget.dart (8 usages)
- lib/dialogs/notification_permission_dialog.dart (1 usage)
- lib/widgets/lost_pet_card.dart (2 usages)
- lib/pages/detailed_schedule_page.dart (3 usages)
- lib/pages/booking_page.dart (4 usages)
- lib/pages/vet_patients_page.dart (1 usage)
- lib/pages/vet_basic_info_page.dart (1 usage)
- lib/pages/help_center_page.dart (2 usages)
- lib/pages/admin/pet_id_management_page.dart (4 usages)
- lib/dialogs/report_missing_pet_dialog.dart (3 usages)
- lib/dialogs/location_picker_dialog.dart (1 usage)
- lib/pages/admin/add_aliexpress_product_page.dart (3 usages)
- lib/pages/admin/add_product_page.dart (2 usages)
- lib/pages/store/add_store_product_page.dart (3 usages)
- lib/pages/admin/user_management_page.dart (5 usages)

## Migration Pattern

For each file:

1. **Add Import**:
   ```dart
   import '../widgets/custom_snackbar.dart';
   ```
   
   Note: Adjust path based on file location:
   - `lib/pages/`: `'../widgets/custom_snackbar.dart'`
   - `lib/dialogs/`: `'../widgets/custom_snackbar.dart'`
   - `lib/pages/admin/`: `'../../widgets/custom_snackbar.dart'`
   - `lib/pages/store/`: `'../../widgets/custom_snackbar.dart'`
   - `lib/widgets/`: `'custom_snackbar.dart'`

2. **Replace Error SnackBars** (red background):
   ```dart
   // OLD
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
       content: Text('Error message'),
       backgroundColor: Colors.red,
     ),
   );
   
   // NEW
   CustomSnackBarHelper.showError(
     context,
     'Error message',
   );
   ```

3. **Replace Success SnackBars** (green background):
   ```dart
   // OLD
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
       content: Text('Success message'),
       backgroundColor: Colors.green,
     ),
   );
   
   // NEW
   CustomSnackBarHelper.showSuccess(
     context,
     'Success message',
   );
   ```

4. **Replace Info SnackBars** (no background or default):
   ```dart
   // OLD
   ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(
       content: Text('Info message'),
     ),
   );
   
   // NEW
   CustomSnackBarHelper.showInfo(
     context,
     'Info message',
   );
   ```

## Benefits

1. **Consistent Design**: Same look across iOS and Android
2. **Modern Appearance**: Material 3 styling with blur effects
3. **Better UX**: Smooth animations and better positioning
4. **Maintainable**: Centralized styling that can be updated globally
5. **Flexible**: Easy to extend with new types or features

## Testing

The custom SnackBar implementation:
- ✅ Handles multiple messages in sequence without overlap
- ✅ Respects ScaffoldMessenger's queue system
- ✅ Supports custom durations
- ✅ Works with action buttons
- ✅ Dismissible by swipe down
- ✅ Properly animates in/out






































