/*

Profile Repository - Outlines the Possible Profile Operations for this app.

*/

import 'package:loom/features/profile/domain/entities/profile_user.dart';

abstract class ProfileRepo {
  Future<ProfileUser?> getProfileUser(String uid);
  Future<void> updateProfile(ProfileUser updatedProfile);
  Future<void> toggleFollow(String currentUserId, String targetUserId);
}
