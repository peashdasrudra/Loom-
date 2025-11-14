import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loom/features/post/domain/entities/post.dart';
import 'package:loom/features/post/domain/repos/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // store the posts in a collection called 'posts'
  final CollectionReference<Map<String, dynamic>> postsCollection =
      FirebaseFirestore.instance.collection('posts');

  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await postsCollection.doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      // get all posts with recents in top
      final postsSnapshot = await postsCollection
          .orderBy('timestamp', descending: true)
          .get();

      // convert each firestore document from json -> list of posts
      final List<Post> allPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data()))
          .toList();

      return allPosts;
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  @override
  Future<List<Post>> fetchPostsByUserId() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('No authenticated user found.');
      }

      final snapshot = await postsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to fetch posts for user: $e');
    }
  }
}
