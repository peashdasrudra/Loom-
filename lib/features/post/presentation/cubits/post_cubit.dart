import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/post/domain/entities/comment.dart';
import 'package:loom/features/post/domain/entities/post.dart';
import 'package:loom/features/post/domain/repos/post_repo.dart';

import 'package:loom/features/post/presentation/cubits/post_states.dart';
import 'package:loom/features/storage/domain/storage_repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({required this.postRepo, required this.storageRepo})
    : super(PostsInitial());

  // Debug: print every state change
  @override
  void onChange(Change<PostState> change) {
    super.onChange(change);
    print(
      '🔄 PostCubit state changed: ${change.currentState} → ${change.nextState}',
    );
  }

  //create a new post
  Future<void> createPost(
    Post post, {
    String? imagePath,
    Uint8List? imageBytes,
  }) async {
    String? imageUrl;

    try {
      // Namespaced filename inside Supabase bucket
      // example: "user123/1700000000000"
      final filename = post.id;

      // ----------------- MOBILE -----------------
      if (imagePath != null) {
        emit(PostsUploading());
        imageUrl = await storageRepo.uploadPostImageMobile(
          imagePath,
          post.userId,
          filename,
        );
      }
      // ----------------- WEB --------------------
      else if (imageBytes != null) {
        emit(PostsUploading());
        imageUrl = await storageRepo.uploadPostImageWeb(
          imageBytes,
          post.userId,
          filename,
        );
      }

      // Build final post with the uploaded image URL
      final newPost = post.copyWith(imageUrl: imageUrl);

      // Store in Firestore
      await postRepo.createPost(newPost);

      // Refresh posts
      await fetchAllPosts();
    } catch (e) {
      emit(PostsError("Failed to create post: $e"));
    }
  }

  // fetch all posts
  Future<void> fetchAllPosts() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("Failed to fetch posts: $e"));
    }
  }

  // delete a post
  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
    } catch (e) {
      emit(PostsError("Failed to delete post: $e"));
    }
  }

  // toggle like in a post
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      await postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostsError("Failed to toggle like: $e"));
    }
  }

  // add a comment to a Post
  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepo.addComment(postId, comment);

      await fetchAllPosts();
    } catch (e) {
      emit(PostsError('Failed to add Comment: $e'));
    }
  }

  // delete comment from a post
  Future<void> deleteComment(String postId, commentId) async {
    try {
      await postRepo.deleteComment(postId, commentId);

      await fetchAllPosts();
    } catch (e) {
      emit(PostsError("Failed to delete comment: $e"));
    }
  }
}
