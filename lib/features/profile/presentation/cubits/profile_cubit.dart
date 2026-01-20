// lib/features/profile/presentation/cubits/profile_cubit.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/profile/domain/repos/profile_repo.dart';
import 'package:loom/features/storage/data/supabase_storage_repo.dart';
import 'profile_states.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final SupabaseStorageRepo storageRepo;

  ProfileCubit({required this.profileRepo, required this.storageRepo})
    : super(ProfileInitial());

  Future<void> fetchProfileUser(String uid) async {
    emit(ProfileLoading());
    final user = await profileRepo.getProfileUser(uid);
    if (user == null) {
      emit(ProfileError(message: 'Profile not found'));
    } else {
      emit(ProfileLoaded(user));
    }
  }

  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    await profileRepo.toggleFollow(currentUserId, targetUserId);
  }

  Future<void> updateProfile({
    required String uid,
    String? newBio,
    String? imageMobilePath,
    Uint8List? imageWebBytes,
  }) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    String imageUrl = currentState.profileUser.profileImageUrl;

    if (imageMobilePath != null) {
      final uploadedUrl = await storageRepo.uploadProfileImageMobile(
        imageMobilePath,
        uid,
        'profile',
      );

      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      }
    } else if (imageWebBytes != null) {
      final uploadedUrl = await storageRepo.uploadProfileImageWeb(
        imageWebBytes,
        uid,
        'profile',
      );

      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      }
    }

    final updatedUser = currentState.profileUser.copyWith(
      bio: newBio,
      profileImageUrl: imageUrl,
    );

    await profileRepo.updateProfile(updatedUser);
    emit(ProfileLoaded(updatedUser));
  }
}
