import 'dart:io';
import 'dart:typed_data';

class FileObject {
  final String name;
  final String id;
  final DateTime createdAt;
  final int size;

  FileObject({
    required this.name,
    required this.id,
    required this.createdAt,
    required this.size,
  });
}

class StorageService {
  // Mock in-memory file storage
  static final Map<String, List<Map<String, dynamic>>> _mockBuckets = {};

  static const String proposalBucket = 'proposal-attachments';

  /// Upload a file (mock version)
  Future<String?> uploadFile({
    required File file,
    required String bucketName,
    required String folderPath,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final filePath = '$folderPath/$fileName';

      // Simulate file upload
      await Future.delayed(const Duration(milliseconds: 300));
      _mockBuckets.putIfAbsent(bucketName, () => []);
      _mockBuckets[bucketName]!.add({
        'path': filePath,
        'size': await file.length(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Return mock public URL
      final publicUrl =
          'https://mock-storage.local/$bucketName/$filePath';

      print('✅ Mock file uploaded: $filePath');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading file: $e');
      return null;
    }
  }

  /// Upload a file from bytes (web support)
  Future<String?> uploadFileFromBytes({
    required List<int> fileBytes,
    required String fileName,
    required String bucketName,
    required String folderPath,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$folderPath/${timestamp}_$fileName';

      // Simulate file upload
      await Future.delayed(const Duration(milliseconds: 300));
      _mockBuckets.putIfAbsent(bucketName, () => []);
      _mockBuckets[bucketName]!.add({
        'path': filePath,
        'size': fileBytes.length,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Return mock public URL
      final publicUrl =
          'https://mock-storage.local/$bucketName/$filePath';

      print('✅ Mock file uploaded: $filePath');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading file: $e');
      return null;
    }
  }

  /// Download a file (mock version)
  Future<List<int>?> downloadFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      // Simulate file download
      await Future.delayed(const Duration(milliseconds: 200));
      print('✅ Mock file downloaded: $filePath');
      return Uint8List.fromList([]);
    } catch (e) {
      print('❌ Error downloading file: $e');
      return null;
    }
  }

  /// Delete a file (mock version)
  Future<bool> deleteFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      // Simulate file deletion
      await Future.delayed(const Duration(milliseconds: 200));
      if (_mockBuckets.containsKey(bucketName)) {
        _mockBuckets[bucketName]!
            .removeWhere((f) => f['path'] == filePath);
      }
      print('✅ Mock file deleted: $filePath');
      return true;
    } catch (e) {
      print('❌ Error deleting file: $e');
      return false;
    }
  }

  /// List files in a bucket folder (mock version)
  Future<List<FileObject>> listFiles({
    required String bucketName,
    required String folderPath,
  }) async {
    try {
      // Simulate listing files
      await Future.delayed(const Duration(milliseconds: 200));
      if (!_mockBuckets.containsKey(bucketName)) {
        return [];
      }

      final files = _mockBuckets[bucketName]!
          .where((f) =>
              (f['path'] as String).startsWith(folderPath))
          .map((f) => FileObject(
                name: (f['path'] as String).split('/').last,
                id: f['path'],
                createdAt: DateTime.parse(f['createdAt'] as String),
                size: f['size'] as int,
              ))
          .toList();

      print('✅ Mock listed files in $folderPath');
      return files;
    } catch (e) {
      print('❌ Error listing files: $e');
      return [];
    }
  }

  /// Get public URL for a file (mock version)
  String getPublicUrl({required String bucketName, required String filePath}) {
    return 'https://mock-storage.local/$bucketName/$filePath';
  }

  /// Check if bucket exists, if not create it
  Future<void> ensureBucketExists(String bucketName) async {
    try {
      _mockBuckets.putIfAbsent(bucketName, () => []);
      print('✅ Mock bucket ready: $bucketName');
    } catch (e) {
      print('⚠️ Error with mock bucket: $bucketName');
    }
  }
}
