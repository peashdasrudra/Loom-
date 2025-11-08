// H:/Loom/lib/features/profile/presentation/cubits/profile_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/profile/domain/repos/profile_repo.dart';
import 'package:loom/features/profile/presentation/cubits/profile_states.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;

  ProfileCubit({required this.profileRepo}) : super(ProfileInitial());

  // Fetch Profile User Data
  Future<void> fetchProfileUser(String uid) async {
    emit(ProfileLoading());
    try {
      final user = await profileRepo.getProfileUser(uid);
      if (user != null) {
        // Correctly passing 'user' as a positional argument.
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError('User not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // Update Profile User Data
  Future<void> updateProfile({required String uid, String? newBio}) async {
    emit(ProfileLoading());
    try {
      // Get current profile user
      final currentUser = await profileRepo.getProfileUser(uid);

      if (currentUser == null) {
        emit(ProfileError('Failed to fetch current user data'));
        return;
      }

      // profile picture update
      // TODO: Implement profile picture update logic here.

      // Update new profile details
      final updatedProfile = currentUser.copyWith(newBio: newBio);

      // Save updated profile to repository
      await profileRepo.updateProfile(updatedProfile);

      // Correctly passing 'updatedProfile' as a positional argument.
      await fetchProfileUser(uid);
    } catch (e) {
      emit(ProfileError('Error Updating Profile: $e'));
    }
  }
}
