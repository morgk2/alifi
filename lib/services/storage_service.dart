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
      await _supabase.storage.from(petPhotosBucket).remove([filePath]);
    } catch (e) {
      print('Error deleting file: $e');
      throw Exception('Failed to delete file: $e');
    }
  }
} 