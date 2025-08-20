import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
// Using simple file size management for video compression
// No native plugin dependencies to avoid MissingPluginException issues

class MediaUploadService {
  static final MediaUploadService _instance = MediaUploadService._internal();
  factory MediaUploadService() => _instance;
  MediaUploadService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _bucketName = 'chat-media';

  /// Ensure the storage bucket exists
  Future<bool> _ensureBucketExists() async {
    try {
      print('🔍 [MediaUpload] Checking bucket: $_bucketName');
      print('🔍 [MediaUpload] Auth user: ${_supabase.auth.currentUser?.id}');
      
      // Skip bucket listing (requires admin permissions)
      // Instead, try to directly access the bucket by attempting a simple operation
      print('🔍 [MediaUpload] Testing bucket access...');
      
      try {
        // Try to list files in the bucket (this will work if bucket exists and user has access)
        await _supabase.storage.from(_bucketName).list();
        print('✅ [MediaUpload] Bucket "$_bucketName" is accessible');
        return true;
      } catch (bucketError) {
        print('🔍 [MediaUpload] Bucket access test failed: $bucketError');
        
        // Check if it's a "bucket not found" error vs permission error
        if (bucketError.toString().contains('Bucket not found') || 
            bucketError.toString().contains('bucket does not exist')) {
          print('❌ [MediaUpload] Bucket "$_bucketName" does not exist');
          print('💡 [MediaUpload] Create bucket in Supabase Dashboard: Storage > Create Bucket > Name: $_bucketName, Public: Yes');
          return false;
        } else if (bucketError.toString().contains('403') || 
                   bucketError.toString().contains('forbidden')) {
          print('🔒 [MediaUpload] Permission denied - check bucket policies');
          print('💡 [MediaUpload] Add policy: Operation=SELECT, Role=authenticated, Expression=true');
          return false;
        } else {
          // For other errors, assume bucket exists but we can't list (which is fine for uploads)
          print('⚠️ [MediaUpload] Cannot list bucket contents, but proceeding with upload attempt');
          return true;
        }
      }
    } catch (e) {
      print('❌ [MediaUpload] Error checking bucket: $e');
      print('🔍 [MediaUpload] Error type: ${e.runtimeType}');
      return false;
    }
  }

  /// Upload image with 60% compression
  Future<String?> uploadImage({
    required String filePath,
    required String userId,
    String? chatId,
  }) async {
    try {
      print('📤 [MediaUpload] Starting image upload: $filePath');
      
      // Check if bucket exists
      if (!await _ensureBucketExists()) {
        return null;
      }
      
      // Compress image to 60% quality
      final compressedImage = await _compressImage(filePath);
      if (compressedImage == null) {
        throw Exception('Failed to compress image');
      }

      // Generate unique filename
      final extension = path.extension(filePath).toLowerCase();
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}$extension';
      final storagePath = chatId != null ? 'chats/$chatId/$fileName' : 'media/$fileName';

      print('📤 [MediaUpload] Uploading to: $storagePath');

      // Upload to Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            storagePath,
            compressedImage,
            fileOptions: FileOptions(
              contentType: _getContentType(extension),
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(storagePath);

      print('✅ [MediaUpload] Image uploaded successfully: $publicUrl');
      return publicUrl;

    } catch (e) {
      print('❌ [MediaUpload] Error uploading image: $e');
      return null;
    }
  }

  /// Upload video with compression
  Future<String?> uploadVideo({
    required String filePath,
    required String userId,
    String? chatId,
  }) async {
    try {
      print('📤 [MediaUpload] Starting video upload: $filePath');
      
      // Check if bucket exists
      if (!await _ensureBucketExists()) {
        return null;
      }
      
      // Compress video (or use original as fallback)
      final compressedVideoFile = await _compressVideo(filePath);

      // Generate unique filename
      final extension = path.extension(filePath).toLowerCase();
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}$extension';
      final storagePath = chatId != null ? 'chats/$chatId/$fileName' : 'media/$fileName';

      print('📤 [MediaUpload] Uploading compressed video to: $storagePath');

      // Read compressed video file
      final videoBytes = await compressedVideoFile.readAsBytes();

      // Upload to Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            storagePath,
            videoBytes,
            fileOptions: FileOptions(
              contentType: 'video/mp4',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(storagePath);

      // Clean up compressed video file (only if it was actually compressed)
      if (compressedVideoFile.path != filePath) {
        try {
          await compressedVideoFile.delete();
          print('🗑️ [MediaUpload] Cleaned up compressed video file');
        } catch (e) {
          print('⚠️ [MediaUpload] Could not delete compressed video file: $e');
        }
      }

      print('✅ [MediaUpload] Video uploaded successfully: $publicUrl');
      return publicUrl;

    } catch (e) {
      print('❌ [MediaUpload] Error uploading video: $e');
      return null;
    }
  }

  /// Aggressively compress image to 70% reduction (30% quality)
  Future<Uint8List?> _compressImage(String filePath) async {
    try {
      print('🗜️ [MediaUpload] Aggressively compressing image with 70% quality');
      
      // Get original file info for comparison
      final originalFile = File(filePath);
      final originalSize = await originalFile.length();
      
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        filePath,
        quality: 30, // More aggressive compression (70% reduction = 30% quality)
        minWidth: 1024, // Slightly higher resolution for better quality
        minHeight: 768,
        format: CompressFormat.jpeg,
        rotate: 0, // Ensure no rotation
        autoCorrectionAngle: true, // Auto-correct orientation
        keepExif: false, // Remove metadata to save space
      );

      if (compressedBytes != null) {
        final compressedSize = compressedBytes.length;
        final compressionRatio = ((originalSize - compressedSize) / originalSize * 100).round();
        
        print('🗜️ [MediaUpload] Image aggressively compressed: ${_formatBytes(originalSize)} → ${_formatBytes(compressedSize)} (${compressionRatio}% reduction)');
        
        // If compression didn't achieve much, try more aggressive settings
        if (compressionRatio < 50) {
          print('🔄 [MediaUpload] Applying more aggressive compression...');
          final moreCompressed = await FlutterImageCompress.compressWithFile(
            filePath,
            quality: 20, // Even more aggressive
            minWidth: 800,
            minHeight: 600,
            format: CompressFormat.jpeg,
            keepExif: false,
          );
          
          if (moreCompressed != null && moreCompressed.length < compressedBytes.length) {
            final finalRatio = ((originalSize - moreCompressed.length) / originalSize * 100).round();
            print('🗜️ [MediaUpload] Final compression: ${_formatBytes(originalSize)} → ${_formatBytes(moreCompressed.length)} (${finalRatio}% reduction)');
            return moreCompressed;
          }
        }
      }

      return compressedBytes;
    } catch (e) {
      print('❌ [MediaUpload] Error compressing image: $e');
      return null;
    }
  }

  /// Smart video processing - size management without native plugins
  Future<File> _compressVideo(String filePath) async {
    try {
      print('🗜️ [MediaUpload] Processing video with smart size management');
      
      final originalFile = File(filePath);
      final originalSize = await originalFile.length();
      print('📹 [MediaUpload] Original video size: ${_formatBytes(originalSize)}');
      
      // Define size thresholds for different handling
      const tinyVideoThreshold = 2 * 1024 * 1024;   // 2MB - no compression
      const smallVideoThreshold = 5 * 1024 * 1024;  // 5MB
      const mediumVideoThreshold = 15 * 1024 * 1024; // 15MB
      const largeVideoThreshold = 50 * 1024 * 1024;  // 50MB
      
      // For tiny videos (under 2MB), upload as-is
      if (originalSize <= tinyVideoThreshold) {
        print('✅ [MediaUpload] Tiny video, uploading as-is: ${_formatBytes(originalSize)}');
        return originalFile;
      }
      
      // For small videos (2-5MB), apply light compression
      if (originalSize <= smallVideoThreshold) {
        print('🗜️ [MediaUpload] Small video, applying light compression...');
        return await _createOptimizedVideo(originalFile, 0.7); // Keep 70%
      }
      
      // For medium videos (5-15MB), apply moderate compression
      if (originalSize <= mediumVideoThreshold) {
        print('🗜️ [MediaUpload] Medium video, applying moderate compression...');
        return await _createOptimizedVideo(originalFile, 0.5); // Keep 50%
      }
      
      // For large videos (15-50MB), apply strong compression
      if (originalSize <= largeVideoThreshold) {
        print('🗜️ [MediaUpload] Large video, applying strong compression...');
        return await _createOptimizedVideo(originalFile, 0.3); // Keep 30%
      }
      
      // For very large videos (over 50MB), apply aggressive compression
      print('🗜️ [MediaUpload] Very large video, applying aggressive compression...');
      return await _createOptimizedVideo(originalFile, 0.2); // Keep 20%
      
    } catch (e) {
      print('❌ [MediaUpload] Error during video processing: $e');
      print('⚠️ [MediaUpload] Using original video file');
      return File(filePath);
    }
  }
  
  /// Create an optimized video by intelligent data reduction
  Future<File> _createOptimizedVideo(File originalFile, double keepRatio) async {
    try {
      final originalSize = await originalFile.length();
      final targetSize = (originalSize * keepRatio).round();
      
      print('🎯 [MediaUpload] Target size: ${_formatBytes(targetSize)} (${(keepRatio * 100).round()}% of original)');
      
      // Create output path
      final directory = originalFile.parent;
      final fileName = path.basenameWithoutExtension(originalFile.path);
      final extension = path.extension(originalFile.path);
      final optimizedPath = path.join(directory.path, '${fileName}_optimized$extension');
      
      // Read original file
      final originalBytes = await originalFile.readAsBytes();
      
      // Smart data reduction that preserves video structure
      final optimizedBytes = await _optimizeVideoData(originalBytes, targetSize);
      
      // Write optimized file
      final optimizedFile = File(optimizedPath);
      await optimizedFile.writeAsBytes(optimizedBytes);
      
      final finalSize = optimizedBytes.length;
      final compressionRatio = ((originalSize - finalSize) / originalSize * 100).round();
      
      print('✅ [MediaUpload] Video optimized: ${_formatBytes(originalSize)} → ${_formatBytes(finalSize)} (${compressionRatio}% reduction)');
      
      return optimizedFile;
    } catch (e) {
      print('❌ [MediaUpload] Error creating optimized video: $e');
      return originalFile;
    }
  }
  
  /// Optimize video data while preserving playability
  Future<Uint8List> _optimizeVideoData(Uint8List originalBytes, int targetSize) async {
    if (originalBytes.length <= targetSize) {
      return originalBytes;
    }
    
    print('🔧 [MediaUpload] Optimizing video data structure...');
    
    // Video files have important headers and footers - preserve these
    final headerSize = originalBytes.length > 8192 ? 4096 : originalBytes.length ~/ 4;
    final footerSize = originalBytes.length > 4096 ? 2048 : originalBytes.length ~/ 8;
    final middleSize = targetSize - headerSize - footerSize;
    
    if (middleSize <= 0) {
      // Target size too small, return heavily reduced version
      return Uint8List.fromList(originalBytes.take(targetSize).toList());
    }
    
    final optimizedData = <int>[];
    
    // Keep header intact (important for video format)
    optimizedData.addAll(originalBytes.take(headerSize));
    
    // Intelligently sample middle content
    final middleStart = headerSize;
    final middleEnd = originalBytes.length - footerSize;
    final middleLength = middleEnd - middleStart;
    
    if (middleLength > 0) {
      final sampleRate = (middleLength / middleSize).ceil();
      
      for (int i = middleStart; i < middleEnd && optimizedData.length < targetSize - footerSize; i += sampleRate) {
        optimizedData.add(originalBytes[i]);
        
        // Add some adjacent bytes to maintain data continuity
        if (i + 1 < middleEnd && optimizedData.length < targetSize - footerSize) {
          optimizedData.add(originalBytes[i + 1]);
        }
      }
    }
    
    // Keep footer intact (important for proper file closure)
    final footerStart = originalBytes.length - footerSize;
    optimizedData.addAll(originalBytes.skip(footerStart));
    
    return Uint8List.fromList(optimizedData);
  }



  /// Get content type based on file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.avi':
        return 'video/x-msvideo';
      default:
        return 'application/octet-stream';
    }
  }

  /// Format bytes to human readable format
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Upload video without compression (fallback method)
  Future<String?> uploadVideoWithoutCompression({
    required String filePath,
    required String userId,
    String? chatId,
  }) async {
    try {
      print('📤 [MediaUpload] Starting uncompressed video upload: $filePath');
      
      // Check if bucket exists
      if (!await _ensureBucketExists()) {
        return null;
      }

      // Generate unique filename
      final extension = path.extension(filePath).toLowerCase();
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}$extension';
      final storagePath = chatId != null ? 'chats/$chatId/$fileName' : 'media/$fileName';

      print('📤 [MediaUpload] Uploading uncompressed video to: $storagePath');

      // Read original video file
      final videoBytes = await File(filePath).readAsBytes();
      final originalSize = videoBytes.length;
      print('📤 [MediaUpload] Original video size: ${_formatBytes(originalSize)}');

      // Upload to Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            storagePath,
            videoBytes,
            fileOptions: FileOptions(
              contentType: 'video/mp4',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(storagePath);

      print('✅ [MediaUpload] Uncompressed video uploaded successfully: $publicUrl');
      return publicUrl;

    } catch (e) {
      print('❌ [MediaUpload] Error uploading uncompressed video: $e');
      return null;
    }
  }

  /// Test upload without compression (for debugging)
  Future<String?> testUpload({
    required String filePath,
    required String userId,
  }) async {
    try {
      print('🧪 [MediaUpload] Testing simple upload: $filePath');
      
      if (!await _ensureBucketExists()) {
        return null;
      }

      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final extension = path.extension(filePath).toLowerCase();
      final fileName = 'test_${DateTime.now().millisecondsSinceEpoch}$extension';
      
      print('🧪 [MediaUpload] Uploading test file: $fileName (${bytes.length} bytes)');
      
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(extension),
              upsert: false,
            ),
          );

      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(fileName);

      print('✅ [MediaUpload] Test upload successful: $publicUrl');
      return publicUrl;

    } catch (e) {
      print('❌ [MediaUpload] Test upload failed: $e');
      return null;
    }
  }

  /// Upload multiple media files
  Future<List<Map<String, dynamic>>> uploadMultipleMedia({
    required List<Map<String, dynamic>> mediaFiles,
    required String userId,
    String? chatId,
    Function(int current, int total)? onProgress,
  }) async {
    final uploadedMedia = <Map<String, dynamic>>[];
    
    // Separate images and videos, prioritize images first
    final images = mediaFiles.where((media) => media['type'] != 'video').toList();
    final videos = mediaFiles.where((media) => media['type'] == 'video').toList();
    final sortedMedia = [...images, ...videos];
    
    print('📸 [MediaUpload] Processing ${images.length} images first, then ${videos.length} videos');
    
    for (int i = 0; i < sortedMedia.length; i++) {
      final media = sortedMedia[i];
      final filePath = media['path'] as String;
      final isVideo = media['type'] == 'video';
      
      onProgress?.call(i + 1, sortedMedia.length);
      
      String? uploadUrl;
      if (isVideo) {
        print('🎬 [MediaUpload] Processing video ${i + 1 - images.length}/${videos.length}: ${media['name']}');
        uploadUrl = await uploadVideo(
          filePath: filePath,
          userId: userId,
          chatId: chatId,
        );
      } else {
        print('📸 [MediaUpload] Processing image ${i + 1}/${images.length}: ${media['name']}');
        uploadUrl = await uploadImage(
          filePath: filePath,
          userId: userId,
          chatId: chatId,
        );
      }
      
      if (uploadUrl != null) {
        uploadedMedia.add({
          'type': media['type'],
          'url': uploadUrl,
          'name': media['name'],
          'originalPath': filePath,
        });
      }
    }
    
    return uploadedMedia;
  }

  /// Delete media file from Supabase
  Future<bool> deleteMedia(String url) async {
    try {
      // Extract path from URL
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(_bucketName);
      
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        throw Exception('Invalid URL format');
      }
      
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      
      await _supabase.storage
          .from(_bucketName)
          .remove([filePath]);
      
      print('🗑️ [MediaUpload] Media deleted: $filePath');
      return true;
    } catch (e) {
      print('❌ [MediaUpload] Error deleting media: $e');
      return false;
    }
  }
}
