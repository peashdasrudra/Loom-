import 'package:loom/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String bio;
  final String profileImageUrl;

  ProfileUser({
    required  super.uid,
    required super.email,
    required super.name,
    required this.bio,
    required this.profileImageUrl,
  });

  // method to update profile user details
  ProfileUser copyWith({
    String? newBio,
    String? newProfileImageUrl,
  }) {
    return ProfileUser(
      uid: uid,
      email: email,
      name: name,
      bio: newBio ?? bio,
      profileImageUrl: newProfileImageUrl ??  profileImageUrl,
    );
  }

  // Convert Profile User -> json
  @override
  Map<String, dynamic> toJson(){
    return{
      'uid': uid,
      'email': email,
      'name': name,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Convert json -> Profile User
  factory ProfileUser.fromJson (Map<String, dynamic> json){
    return ProfileUser(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      bio: json['bio'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }


}
