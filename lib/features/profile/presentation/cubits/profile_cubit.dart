import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/profile/domain/entities/profile_user.dart';
import 'package:loom/features/profile/domain/repos/profile_repo.dart';
import 'package:loom/features/profile/presentation/cubits/profile_states.dart';
import 'package:loom/features/storage/domain/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({required this.profileRepo, required this.storageRepo})
    : super(ProfileInitial());

  // Fetch Profile User Data
  Future<void> fetchProfileUser(String uid) async {
    emit(ProfileLoading());
    try {
      final user = await profileRepo.getProfileUser(uid);
      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError('User not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // Get profile for other features (posts, comments, etc.)
  Future<ProfileUser?> getUserProfile(String uid) async {
    return profileRepo.getProfileUser(uid);
  }

  // Update Profile User Data
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  }) async {
    emit(ProfileLoading());

    try {
      final currentUser = await profileRepo.getProfileUser(uid);
      if (currentUser == null) {
        emit(ProfileError('Failed to fetch current user data'));
        return;
      }

      String? imageDownloadUrl;

      // Upload image if provided
      if (imageWebBytes != null || imageMobilePath != null) {
        const fileName = 'profile'; // ✅ REQUIRED third argument

        if (imageMobilePath != null) {
          imageDownloadUrl = await storageRepo.uploadProfileImageMobile(
            imageMobilePath,
            uid,
            fileName,
          );
        } else if (imageWebBytes != null) {
          imageDownloadUrl = await storageRepo.uploadProfileImageWeb(
            imageWebBytes,
            uid,
            fileName,
          );
        }

        if (imageDownloadUrl == null) {
          emit(ProfileError('Failed to upload profile image'));
          return;
        }
      }

      final updatedProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
      );

      await profileRepo.updateProfile(updatedProfile);

      // Emit updated state immediately
      emit(ProfileLoaded(updatedProfile));

      // Optional refresh
      try {
        await fetchProfileUser(uid);
      } catch (_) {}
    } catch (e, st) {
      print('ProfileCubit error: $e\n$st');
      emit(ProfileError('Error updating profile'));
    }
  }
}
