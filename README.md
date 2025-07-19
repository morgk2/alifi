# Alifi - Pet Care App

A Flutter app for pet care and management.

## Optimization TODOs

- [x] Replace all Image.network usages with CachedNetworkImage and add placeholders/fade-in effects.
- [x] Add const constructors and const widgets wherever possible throughout lib/.
- [x] Refactor all ListView and PageView usages to use builder constructors and wrap heavy list items in RepaintBoundary.
- [x] Minimize setState usage by extracting stateful logic to smaller widgets or using ValueListenableBuilder/Provider where possible.
- [ ] Compress and resize user-uploaded images before saving or displaying using the image or flutter_image_compress package.
- [ ] Extract deeply nested widgets into smaller, reusable widgets for better performance and readability.

## Completed Optimizations

### 1. Image Caching Optimization ✅
- Replaced all `Image.network` usages with `CachedNetworkImage`
- Added placeholder images and fade-in effects
- Improved loading performance and user experience

### 2. Const Constructor Optimization ✅
- Added `const` constructors throughout the codebase
- Reduced widget rebuilds and improved performance
- Applied to widgets that don't change state

### 3. ListView/PageView Builder Optimization ✅
- Refactored all `ListView` and `PageView` usages to use builder constructors
- Wrapped heavy list items in `RepaintBoundary` for better performance
- Improved scrolling performance and reduced memory usage

### 4. setState Usage Minimization ✅
- Replaced frequently updated state variables with `ValueNotifier`
- Used `ValueListenableBuilder` for localized widget rebuilds
- Refactored HomePage, MyPetsPage, AddPetDialog, and EditProfilePage
- Reduced unnecessary widget tree rebuilds and improved performance

## Performance Improvements Achieved

1. **Reduced Widget Rebuilds**: By using `ValueNotifier` and `ValueListenableBuilder`, we've minimized unnecessary widget rebuilds throughout the app.

2. **Better Memory Management**: Proper disposal of `ValueNotifier` instances and optimized list rendering.

3. **Improved Scrolling Performance**: Builder constructors and `RepaintBoundary` usage for smooth scrolling.

4. **Enhanced Image Loading**: Cached network images with placeholders for better UX.

5. **Optimized State Management**: Localized state updates instead of full widget tree rebuilds.

## Next Steps

The remaining optimizations focus on:
- Image compression for user uploads
- Widget extraction for better code organization and performance
