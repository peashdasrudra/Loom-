// lib/features/storage/data/supabase_storage_repo.dart

import 'dart:io' show File;
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:loom/features/storage/domain/storage_repo.dart';

class SupabaseStorageRepo implements StorageRepo {
  final _client = Supabase.instance.client;

  // Bucket names (create these in Supabase dashboard -> Storage)
  final String _profileBucket = 'profile_images';
  final String _postBucket = 'post_media';

  // ---------------- Profile (mobile) ----------------
  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) async {
    try {
      final file = File(path);
      final ext = p.extension(path);
      final filePath = ext.isNotEmpty ? '$fileName$ext' : fileName;

      // upload
      await _client.storage
          .from(_profileBucket)
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      // return public url (works if bucket is public)
      final publicUrl = _client.storage
          .from(_profileBucket)
          .getPublicUrl(filePath);
      print('Supabase: uploaded profile mobile -> $publicUrl');
      return publicUrl;
    } catch (e, st) {
      print('Supabase uploadProfileImageMobile error: $e\n$st');
      return null;
    }
  }

  // ---------------- Profile (web) ----------------
  @override
  Future<String?> uploadProfileImageWeb(
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      final filePath = fileName.contains('.') ? fileName : '$fileName.png';

      await _client.storage
          .from(_profileBucket)
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _client.storage
          .from(_profileBucket)
          .getPublicUrl(filePath);
      print('Supabase: uploaded profile web -> $publicUrl');
      return publicUrl;
    } catch (e, st) {
      print('Supabase uploadProfileImageMWeb error: $e\n$st');
      return null;
    }
  }

  // ---------------- Post image (mobile) ----------------
  @override
  Future<String?> uploadPostImageMobile(String path, String fileName) async {
    try {
      final file = File(path);
      final ext = p.extension(path);
      final filePath = ext.isNotEmpty ? '$fileName$ext' : fileName;

      await _client.storage
          .from(_postBucket)
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      final publicUrl = _client.storage
          .from(_postBucket)
          .getPublicUrl(filePath);
      print('Supabase: uploaded post mobile -> $publicUrl');
      return publicUrl;
    } catch (e, st) {
      print('Supabase uploadPostImageMobile error: $e\n$st');
      return null;
    }
  }

  // ---------------- Post image (web) ----------------
  @override
  Future<String?> uploadPostImageWeb(
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      final filePath = fileName.contains('.') ? fileName : '$fileName.png';

      await _client.storage
          .from(_postBucket)
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _client.storage
          .from(_postBucket)
          .getPublicUrl(filePath);
      print('Supabase: uploaded post web -> $publicUrl');
      return publicUrl;
    } catch (e, st) {
      print('Supabase uploadPostImageWeb error: $e\n$st');
      return null;
    }
  }
}
