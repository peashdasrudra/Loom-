import 'dart:io' show File;
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:loom/features/storage/domain/storage_repo.dart';

class SupabaseStorageRepo implements StorageRepo {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _profileBucket = 'profile_images';
  static const String _postBucket = 'post_media';

  // ================= PROFILE MOBILE =================
  @override
  Future<String?> uploadProfileImageMobile(
    String path,
    String userId,
    String fileName,
  ) async {
    try {
      final file = File(path);
      final ext = p.extension(path);
      final safeName = ext.isNotEmpty ? '$fileName$ext' : '$fileName.jpg';
      final filePath = '$userId/$safeName';

      await _client.storage
          .from(_profileBucket)
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      return _client.storage.from(_profileBucket).getPublicUrl(filePath);
    } catch (e, st) {
      print('uploadProfileImageMobile error: $e\n$st');
      return null;
    }
  }

  // ================= PROFILE WEB =================
  @override
  Future<String?> uploadProfileImageWeb(
    Uint8List fileBytes,
    String userId,
    String fileName,
  ) async {
    try {
      final safeName = fileName.contains('.') ? fileName : '$fileName.png';
      final filePath = '$userId/$safeName';

      await _client.storage
          .from(_profileBucket)
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      return _client.storage.from(_profileBucket).getPublicUrl(filePath);
    } catch (e, st) {
      print('uploadProfileImageWeb error: $e\n$st');
      return null;
    }
  }

  // ================= POST MOBILE =================
  @override
  Future<String?> uploadPostImageMobile(
    String path,
    String userId,
    String fileName,
  ) async {
    try {
      final file = File(path);
      final ext = p.extension(path);
      final safeName = ext.isNotEmpty ? '$fileName$ext' : '$fileName.jpg';
      final filePath = '$userId/$safeName';

      await _client.storage
          .from(_postBucket)
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      return _client.storage.from(_postBucket).getPublicUrl(filePath);
    } catch (e, st) {
      print('uploadPostImageMobile error: $e\n$st');
      return null;
    }
  }

  // ================= POST WEB =================
  @override
  Future<String?> uploadPostImageWeb(
    Uint8List fileBytes,
    String userId,
    String fileName,
  ) async {
    try {
      final safeName = fileName.contains('.') ? fileName : '$fileName.png';
      final filePath = '$userId/$safeName';

      await _client.storage
          .from(_postBucket)
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      return _client.storage.from(_postBucket).getPublicUrl(filePath);
    } catch (e, st) {
      print('uploadPostImageWeb error: $e\n$st');
      return null;
    }
  }
}
