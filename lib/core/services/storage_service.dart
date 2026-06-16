import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _supabase = Supabase.instance.client;

  static const String proposalBucket = 'proposal-attachments';

  /// Upload a file to Supabase Storage from File (mobile)
  Future<String?> uploadFile({
    required File file,
    required String bucketName,
    required String folderPath,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final filePath = '$folderPath/$fileName';

      await _supabase.storage.from(bucketName).upload(filePath, file);

      // Get the public URL
      final publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      print('✅ File uploaded: $filePath');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading file: $e');
      return null;
    }
  }

  /// Upload a file to Supabase Storage from bytes (web support)
  Future<String?> uploadFileFromBytes({
    required List<int> fileBytes,
    required String fileName,
    required String bucketName,
    required String folderPath,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$folderPath/${timestamp}_$fileName';

      // Convert List<int> to Uint8List
      final uint8List = Uint8List.fromList(fileBytes);

      await _supabase.storage
          .from(bucketName)
          .uploadBinary(filePath, uint8List);

      // Get the public URL
      final publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      print('✅ File uploaded: $filePath');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading file: $e');
      return null;
    }
  }

  /// Download a file from Supabase Storage
  Future<List<int>?> downloadFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      final data = await _supabase.storage.from(bucketName).download(filePath);

      print('✅ File downloaded: $filePath');
      return data;
    } catch (e) {
      print('❌ Error downloading file: $e');
      return null;
    }
  }

  /// Delete a file from Supabase Storage
  Future<bool> deleteFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      await _supabase.storage.from(bucketName).remove([filePath]);

      print('✅ File deleted: $filePath');
      return true;
    } catch (e) {
      print('❌ Error deleting file: $e');
      return false;
    }
  }

  /// List files in a bucket folder
  Future<List<FileObject>> listFiles({
    required String bucketName,
    required String folderPath,
  }) async {
    try {
      final files = await _supabase.storage
          .from(bucketName)
          .list(path: folderPath);

      print('✅ Listed files in $folderPath');
      return files;
    } catch (e) {
      print('❌ Error listing files: $e');
      return [];
    }
  }

  /// Get public URL for a file
  String getPublicUrl({required String bucketName, required String filePath}) {
    return _supabase.storage.from(bucketName).getPublicUrl(filePath);
  }

  /// Check if bucket exists, if not create it
  Future<void> ensureBucketExists(String bucketName) async {
    try {
      await _supabase.storage.getBucket(bucketName);
      print('✅ Bucket exists: $bucketName');
    } catch (e) {
      print('⚠️ Bucket not found, attempting to create: $bucketName');
      // Note: Creating buckets from client requires admin privileges
      // This should be done from Supabase dashboard or backend
    }
  }
}
