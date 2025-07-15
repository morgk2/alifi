import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;

class LocalImageService {
  final _uuid = const Uuid();

  // Save a single image to local storage and return its path
  Future<String> saveImage(XFile image) async {
    if (kIsWeb) {
      // For web, we'll just keep the original path as web doesn't support local storage
      return image.path;
    }

    try {
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/pet_images');
      
      // Create the directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate a unique filename
      final filename = '${_uuid.v4()}${path.extension(image.path)}';
      final localPath = '${imagesDir.path}/$filename';

      // Copy the image to our app's local storage
      final File imageFile = File(image.path);
      await imageFile.copy(localPath);

      return localPath;
    } catch (e) {
      print('Error saving image locally: $e');
      rethrow;
    }
  }

  // Save multiple images and return their paths
  Future<List<String>> saveImages(List<XFile> images) async {
    final List<String> paths = [];
    for (final image in images) {
      final path = await saveImage(image);
      paths.add(path);
    }
    return paths;
  }

  // Delete an image by its path
  Future<void> deleteImage(String imagePath) async {
    if (kIsWeb) return; // No deletion needed for web

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting local image: $e');
      rethrow;
    }
  }

  // Delete multiple images
  Future<void> deleteImages(List<String> imagePaths) async {
    for (final path in imagePaths) {
      await deleteImage(path);
    }
  }

  // Clean up unused images (can be called periodically)
  Future<void> cleanupUnusedImages() async {
    if (kIsWeb) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/pet_images');
      
      if (await imagesDir.exists()) {
        await for (final entity in imagesDir.list()) {
          if (entity is File) {
            // Here you could implement logic to check if the image is still referenced
            // by any pet in the local storage before deleting
          }
        }
      }
    } catch (e) {
      print('Error cleaning up images: $e');
    }
  }
} 