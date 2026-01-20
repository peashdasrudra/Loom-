// lib/features/profile/data/repos/firebase_profile_repo.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loom/features/profile/domain/entities/profile_user.dart';
import 'package:loom/features/profile/domain/repos/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser?> getProfileUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return ProfileUser.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> updateProfile(ProfileUser updatedProfile) async {
    await _firestore
        .collection('users')
        .doc(updatedProfile.uid)
        .update(updatedProfile.toJson());
  }

  @override
  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    final targetUserRef = _firestore.collection('users').doc(targetUserId);

    await _firestore.runTransaction((tx) async {
      final targetSnap = await tx.get(targetUserRef);
      final currentSnap = await tx.get(currentUserRef);

      final _ = List<String>.from(targetSnap['followers'] ?? []);
      final currentFollowing = List<String>.from(
        currentSnap['following'] ?? [],
      );

      final isFollowing = currentFollowing.contains(targetUserId);

      if (isFollowing) {
        tx.update(targetUserRef, {
          'followers': FieldValue.arrayRemove([currentUserId]),
        });
        tx.update(currentUserRef, {
          'following': FieldValue.arrayRemove([targetUserId]),
        });
      } else {
        tx.update(targetUserRef, {
          'followers': FieldValue.arrayUnion([currentUserId]),
        });
        tx.update(currentUserRef, {
          'following': FieldValue.arrayUnion([targetUserId]),
        });
      }
    });
  }
}
