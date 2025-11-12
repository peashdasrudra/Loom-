// lib/features/storage/data/supabase_storage_repo.dart

import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loom/features/storage/domain/storage_repo.dart';

class SupabaseStorageRepo implements StorageRepo {
  // get the initialized Supabase client
  final _client = Supabase.instance.client;

  // bucket name (must exist in Supabase dashboard)
  final String _bucket = 'profile_images';

  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) async {
    try {
      final file = File(path);
      final filePath = fileName;

      print(
        'SupabaseStorageRepo.uploadProfileImageMobile -> filePath: $filePath, path: $path',
      );

      // upload file from device storage (mobile)
      await _client.storage
          .from(_bucket)
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      // get public URL (if bucket is public)
      final publicUrl = _client.storage.from(_bucket).getPublicUrl(filePath);
      print(
        'SupabaseStorageRepo.uploadProfileImageMobile -> uploaded url: $publicUrl',
      );

      return publicUrl;
    } catch (e, st) {
      print('Error uploading mobile image: $e\n$st');
      return null;
    }
  }

  @override
  Future<String?> uploadProfileImageMWeb(
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      final filePath = fileName;

      print(
        'SupabaseStorageRepo.uploadProfileImageMWeb -> filePath: $filePath, bytesLength: ${fileBytes.length}',
      );

      // On web, uploadBinary accepts bytes. Don't try to cast to File.
      await _client.storage
          .from(_bucket)
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // get public URL (if bucket is public)
      final publicUrl = _client.storage.from(_bucket).getPublicUrl(filePath);
      print(
        'SupabaseStorageRepo.uploadProfileImageMWeb -> uploaded url: $publicUrl',
      );

      return publicUrl;
    } catch (e, st) {
      print('Error uploading web image: $e\n$st');
      return null;
    }
  }
}
