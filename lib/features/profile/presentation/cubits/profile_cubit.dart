// lib/features/profile/presentation/cubits/profile_cubit.dart

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  // Update Profile User Data
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  }) async {
    print('ProfileCubit: updateProfile called for uid=$uid');
    emit(ProfileLoading());
    try {
      final currentUser = await profileRepo.getProfileUser(uid);
      print('ProfileCubit: currentUser fetched -> $currentUser');

      if (currentUser == null) {
        emit(ProfileError('Failed to fetch current user data'));
        return;
      }

      String? imageDownloadUrl;

      // upload image if present
      if (imageWebBytes != null || imageMobilePath != null) {
        print('ProfileCubit: uploading image...');
        if (imageMobilePath != null) {
          imageDownloadUrl = await storageRepo.uploadProfileImageMobile(
            imageMobilePath,
            uid,
          );
        } else if (imageWebBytes != null) {
          imageDownloadUrl = await storageRepo.uploadProfileImageMWeb(
            imageWebBytes,
            uid,
          );
        }
        print('ProfileCubit: image upload returned -> $imageDownloadUrl');
        if (imageDownloadUrl == null) {
          emit(ProfileError("Failed to upload image"));
          return;
        }
      }

      final updatedProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
      );

      print('ProfileCubit: updating profile in repo -> $updatedProfile');

      await profileRepo.updateProfile(updatedProfile);

      // Emit updated profile immediately so EditProfilePage can pop.
      emit(ProfileLoaded(updatedProfile));

      // Attempt to refresh from server asynchronously (optional).
      try {
        await fetchProfileUser(uid);
      } catch (e) {
        print('ProfileCubit: fetchProfileUser after update failed: $e');
      }
    } catch (e, st) {
      print('ProfileCubit: Error Updating Profile: $e\n$st');
      emit(ProfileError('Error Updating Profile: $e'));
    }
  }
}
