// lib/features/home/presentation/pages/home_page.dart
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loom/features/home/presentation/components/my_drawer.dart';
import 'package:loom/features/home/presentation/components/post_tile.dart';
import 'package:loom/features/post/presentation/cubits/post_cubit.dart';
import 'package:loom/features/post/presentation/cubits/post_states.dart';
import 'package:loom/features/post/presentation/pages/upload_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // post Cubit (read from context)
  late final PostCubit postCubit = context.read<PostCubit>();

  @override
  void initState() {
    super.initState();
    // fetch all posts once on startup
    postCubit.fetchAllPosts();
  }

  // delete post and refresh after deletion
  Future<void> deletePost(String postId) async {
    await postCubit.deletePost(postId);
    // refresh
    postCubit.fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          // upload new post button
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UploadPostPage()),
            ),
            icon: const Icon(Icons.post_add),
          ),
        ],
      ),

      // DRAWER
      drawer: const MyDrawer(),

      // BODY
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          // loading or uploading
          if (state is PostsLoading || state is PostsUploading) {
            return const Center(child: CircularProgressIndicator());
          }

          // loaded
          if (state is PostsLoaded) {
            final allPosts = state.posts;

            if (allPosts.isEmpty) {
              return const Center(child: Text("No Posts Available"));
            }

            return ListView.builder(
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                final post = allPosts[index];

                return PostTile(
                  post: post,
                  onDeletePressed: () => deletePost(post.id),
                );
              },
            );
          }

          // error
          if (state is PostsError) {
            return Center(child: Text(state.message));
          }

          // default fallback
          return const SizedBox();
        },
      ),
    );
  }
}
