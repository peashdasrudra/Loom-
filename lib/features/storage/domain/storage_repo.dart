import 'dart:typed_data';

abstract class StorageRepo {
  // upload profile image on mobile platforms
  Future<String?> uploadProfileImageMobile(String path, String userId, String fileName);

  // upload profile images on web platforms
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String userId, String fileName);

  // upload post image for mobile (path) — called by your PostCubit
  Future<String?> uploadPostImageMobile(String path, String userId, String fileName);

  // upload post image for web (bytes) — called by your PostCubit
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String userId, String fileName);
}
