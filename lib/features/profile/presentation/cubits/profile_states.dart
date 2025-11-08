// H:/Loom/lib/features/profile/presentation/cubits/profile_states.dart

/*

PROFILE STATES

*/

import 'package:loom/features/profile/domain/entities/profile_user.dart';

abstract class ProfileState {}

//initial state
class ProfileInitial extends ProfileState {}

//loading state
class ProfileLoading extends ProfileState {}

//loaded state
class ProfileLoaded extends ProfileState {
  final ProfileUser profileUser;

  // This is a positional constructor.
  ProfileLoaded(this.profileUser);
}

//error state
class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
