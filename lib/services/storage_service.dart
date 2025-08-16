import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _supabase;
  final _uuid = const Uuid();
  static const String petPhotosBucket = 'pet-photos';

  StorageService(this._supabase);

  /// Test function to verify Supabase storage connection
  Future<bool> testConnection() async {
    try {
      print('Testing Supabase storage connection...');
      // Try to list files to test connection
      await _supabase.storage.from(petPhotosBucket).list();
      print('Successfully connected to Supabase storage');
      return true;
    } catch (e) {
      print('Failed to connect to Supabase storage: $e');
      return false;
    }
  }

  /// Uploads a pet photo and returns the public URL
  Future<String> uploadPetPhoto(File photo) async {
    try {
      print('Starting pet photo upload...');
      
      // Generate a unique file name
      final fileExtension = path.extension(photo.path);
      final fileName = '${_uuid.v4()}$fileExtension';
      
      print('Reading file data...');
      
      // Handle file reading based on platform
      Uint8List bytes;
      if (kIsWeb) {
        // For web platform
        final response = await http.get(Uri.file(photo.path));
        bytes = response.bodyBytes;
      } else {
        // For mobile platforms
        bytes = await photo.readAsBytes();
      }
      
      print('Uploading file: $fileName (${bytes.length} bytes)');
      
      // Upload using the Supabase SDK's uploadBinary method
      await _supabase.storage
          .from(petPhotosBucket)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: lookupMimeType(photo.path) ?? 'image/jpeg',
              upsert: true
            ),
          );
      
      // Get the public URL
      final publicUrl = _supabase.storage
          .from(petPhotosBucket)
          .getPublicUrl(fileName);
          
      print('Upload successful. URL: $publicUrl');
      return publicUrl;
    } catch (e, stackTrace) {
      print('Error uploading pet photo: $e');
      print('Stack trace: $stackTrace');
      print('File path: ${photo.path}');
      print('File exists: ${photo.existsSync()}');
      print('File size: ${photo.lengthSync()} bytes');
      rethrow;
    }
  }

  /// Deletes a file from Supabase storage
  Future<void> deleteFile(String filePath) async {
    try {
      print('Attempting to delete file: $filePath from bucket: $petPhotosBucket');
      
      // Check if user is authenticated
      final user = _supabase.auth.currentUser;
      print('Current user: ${user?.id ?? 'Not authenticated'}');
      
      // Try to delete the file
      final response = await _supabase.storage.from(petPhotosBucket).remove([filePath]);
      print('Delete response: $response');
      
      // Wait a moment for the deletion to propagate
      await Future.delayed(Duration(milliseconds: 500));
      
      // Try to list files to see if our file is still there
      try {
        final files = await _supabase.storage.from(petPhotosBucket).list();
        final fileExists = files.any((file) => file.name == filePath);
        if (fileExists) {
          print('File still exists in bucket listing: $filePath');
          throw Exception('File was not actually deleted from bucket');
        } else {
          print('Successfully deleted file: $filePath (verified via listing)');
        }
      } catch (e) {
        print('Error checking file listing: $e');
        // If we can't check the listing, we'll assume deletion worked
        print('Assuming file deletion was successful');
      }
    } catch (e) {
      print('Error deleting file: $e');
      print('File path: $filePath');
      print('Bucket: $petPhotosBucket');
      print('Supabase client: $_supabase');
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Deletes an adoption listing image from Supabase storage
  Future<void> deleteAdoptionListingImage(String imageUrl) async {
    try {
      print('Attempting to delete adoption listing image: $imageUrl');
      
      // Extract file path from the URL
      // URL format: https://xxx.supabase.co/storage/v1/object/public/pet-photos/filename.jpg
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      print('Path segments: $pathSegments');
      
      if (pathSegments.length >= 5 && pathSegments[3] == 'public' && pathSegments[4] == 'pet-photos') {
        final fileName = pathSegments.sublist(5).join('/');
        print('Extracted filename: $fileName');
        await deleteFile(fileName);
        print('Successfully deleted adoption listing image: $fileName');
      } else {
        print('Invalid URL format for Supabase storage. Expected format: /storage/v1/object/public/pet-photos/filename');
        print('Actual path segments: $pathSegments');
        throw Exception('Invalid image URL format');
      }
    } catch (e) {
      print('Error deleting adoption listing image: $e');
      print('Image URL: $imageUrl');
      rethrow;
    }
  }
} 