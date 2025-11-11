import 'dart:typed_data';

abstract class StorageRepo {
  // upload profile image on mobile platforms
  Future<String?> uploadProfileImageMobile(String path, String fileName);

  // upload profile images on web platforms
  Future<String?> uploadProfileImageMWeb(Uint8List fileBytes, String fileName);
}
