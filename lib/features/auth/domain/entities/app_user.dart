class AppUser {
  final String uid;
  final String name;
  final String email;
  final String bio;
  final String profileImageUrl;
  final List<String> followers;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.bio,
    required this.profileImageUrl,
    required this.followers,
  });

  // Convert App User -> json

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'followers': followers,
    };
  }

  // Convert json -> app user

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'],
      name: jsonUser['name'],
      email: jsonUser['email'],
      bio: jsonUser['bio'],
      profileImageUrl: jsonUser['profileImageUrl'],
      followers: List<String>.from(jsonUser['followers'] ?? []),
    );
  }
}
