import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loom/features/auth/domain/entities/app_user.dart';
import 'package:loom/features/auth/domain/repos/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User record not found');
      }

      final data = userDoc.data() as Map<String, dynamic>;

      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? email,
        name: data['name'] ?? '',
        bio: data['bio'] ?? '',
        profileImageUrl: data['profileImageUrl'] ?? '',
        followers: List<String>.from(data['followers'] ?? const []),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    } on FirebaseException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Login failed');
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      final user = AppUser(
        uid: firebaseUser.uid,
        email: email,
        name: name,
        bio: '',
        profileImageUrl: '',
        followers: const [],
      );

      await _firestore.collection('users').doc(user.uid).set(user.toJson());

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    } on FirebaseException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (_) {
      throw Exception('Registration failed');
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) return null;

      final data = userDoc.data() as Map<String, dynamic>;

      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: data['name'] ?? '',
        bio: data['bio'] ?? '',
        profileImageUrl: data['profileImageUrl'] ?? '',
        followers: List<String>.from(data['followers'] ?? const []),
      );
    } catch (_) {
      return null;
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return 'Authentication failed';
    }
  }
}
