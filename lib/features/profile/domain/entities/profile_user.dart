class ProfileUser {
  final String uid;
  final String name;
  final String email;
  final String bio;
  final String profileImageUrl;
  final List<String> followers;
  final List<String> following;

  ProfileUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.bio,
    required this.profileImageUrl,
    required this.followers,
    required this.following,
  });

  ProfileUser copyWith({
    String? name,
    String? bio,
    String? profileImageUrl,
    List<String>? followers,
    List<String>? following,
  }) {
    return ProfileUser(
      uid: uid,
      name: name ?? this.name,
      email: email,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      followers: followers ?? List.from(this.followers),
      following: following ?? List.from(this.following),
    );
  }

  factory ProfileUser.fromJson(String uid, Map<String, dynamic> json) {
    return ProfileUser(
      uid: uid,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'followers': followers,
      'following': following,
    };
  }
}
