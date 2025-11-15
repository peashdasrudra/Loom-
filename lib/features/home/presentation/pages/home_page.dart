// lib/features/home/presentation/pages/home_page.dart
// Production-ready HomePage that works with MainShell:
// - opens MainShell drawer via MainShell.scaffoldKey
// - reserves bottom padding using MainShell.navBaseHeight
// - merges new posts on refresh (no reload of older posts)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loom/features/home/presentation/components/main_shell.dart';
import 'package:loom/features/post/presentation/cubits/post_cubit.dart';
import 'package:loom/features/post/presentation/cubits/post_states.dart';
import 'package:loom/features/post/presentation/pages/upload_post_page.dart';
import 'package:loom/features/home/presentation/components/post_tile.dart';
import 'package:loom/features/post/domain/entities/post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PostCubit postCubit = context.read<PostCubit>();
  final List<Post> _posts = [];
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    postCubit.fetchAllPosts();
  }

  Future<void> deletePost(String postId) async {
    await postCubit.deletePost(postId);
    setState(() => _posts.removeWhere((p) => p.id == postId));
  }

  Future<void> _handleRefresh() async {
    if (_refreshing) return;
    _refreshing = true;
    postCubit.fetchAllPosts();

    final deadline = DateTime.now().add(const Duration(seconds: 6));
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!_refreshing) break;
    }
    _refreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    // Reserve enough bottom space so the feed is not covered by the shell nav.
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double reserved = MainShell.navBaseHeight + bottomInset;
    final EdgeInsets feedPadding = EdgeInsets.fromLTRB(
      12,
      12,
      12,
      reserved + 12,
    );

    return Scaffold(
      // NOTE: do not attach drawer here — it is provided by MainShell.
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // open the top-level drawer reliably
            MainShell.scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          "Home",
          style: TextStyle(
            color: primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        foregroundColor: primary,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadPostPage()),
            ),
            icon: Icon(Icons.post_add, color: primary),
            tooltip: 'Create post',
          ),
        ],
      ),

      body: BlocConsumer<PostCubit, PostState>(
        listener: (context, state) {
          if (state is PostsLoaded) {
            final fetched = (state.posts as List<Post>);
            if (_posts.isEmpty) {
              setState(() => _posts.addAll(fetched));
              _refreshing = false;
              return;
            }

            final existingIds = _posts.map((p) => p.id).toSet();
            final newItems = fetched
                .where((p) => !existingIds.contains(p.id))
                .toList();

            if (newItems.isNotEmpty) {
              setState(() => _posts.insertAll(0, newItems));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    newItems.length == 1
                        ? '1 new post added'
                        : '${newItems.length} new posts added',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            _refreshing = false;
          } else if (state is PostsError) {
            _refreshing = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update feed: ${state.message}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final initialLoading =
              (state is PostsLoading || state is PostsUploading) &&
              _posts.isEmpty;
          if (initialLoading) {
            return Center(
              child: RefreshProgressIndicator(
                value: null,
                strokeWidth: 3.0,
                color: primary,
                backgroundColor: theme.scaffoldBackgroundColor,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: primary,
            displacement: 64,
            child: _posts.isEmpty
                ? ListView(
                    padding: feedPadding,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [SizedBox(height: 20)],
                  )
                : ListView.builder(
                    padding: feedPadding,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return PostTile(
                        post: post,
                        onDeletePressed: () => deletePost(post.id),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
