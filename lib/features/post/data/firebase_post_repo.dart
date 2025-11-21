import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loom/features/post/domain/entities/post.dart';
import 'package:loom/features/post/domain/entities/comment.dart';
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

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      // get the post document from firestore
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // check if the user has already like this post
        final hasLiked = post.likes.contains(userId);

        // update like List
        if (hasLiked) {
          post.likes.remove(userId); // unlike
        } else {
          post.likes.add(userId); // like
        }

        // update the post document with the new like list
        postsCollection.doc(postId).update({'likes': post.likes});
      } else {
        throw Exception("Post Not Found");
      }
    } catch (e) {
      throw Exception("Error toggling like: $e");
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      // get post document
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        // convert json object -> post
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // add the new comment
        post.comments.add(comment);

        // update the post document in firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList(),
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error adding comment: $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      // get post document
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        // convert json object -> post
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // add the new comment
        post.comments.removeWhere((comment) => comment.id == commentId);

        // update the post document in firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList(),
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error deleting comment: $e");
    }
  }
}
