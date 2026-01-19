// lib/features/post/presentation/components/post_tile_final.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:loom/features/post/domain/entities/comment.dart';
import 'package:loom/features/post/domain/entities/post.dart';
import 'package:loom/features/post/presentation/components/comment_tile.dart';
import 'package:loom/features/post/presentation/cubits/post_cubit.dart';
import 'package:loom/features/post/presentation/cubits/post_states.dart';
import 'package:loom/features/profile/domain/entities/profile_user.dart';
import 'package:loom/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:loom/features/auth/presentation/components/my_text_field.dart';
import 'package:loom/features/profile/presentation/pages/profile_page.dart';

/// post_tile_final.dart
/// Polished PostTile with compact comment preview and "See more / Show less".
/// Minimal changes from your original file — mostly the comment preview section.

const double _kAvatarSize = 44.0;

/// Local fallback image (uploaded screenshot). Your environment may transform
/// this path into a usable URL for previewing avatars locally.
const String _localFallbackProfileImage =
    '/mnt/data/ded303bf-de95-4a1b-850d-7615ac5be774.png';

class PostTile extends StatefulWidget {
  final Post post;
  final VoidCallback? onDeletePressed;
  const PostTile({super.key, required this.post, this.onDeletePressed});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> with TickerProviderStateMixin {
  late final PostCubit _postCubit;
  late final ProfileCubit _profileCubit;

  bool isOwnPost = false;
  ProfileUser? postUser;
  User? currentUser;
  bool _showAllComments = false;
  late final Set<String> _localLikes;
  final TextEditingController _commentTextController = TextEditingController();
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _postCubit = context.read<PostCubit>();
    _profileCubit = context.read<ProfileCubit>();
    _localLikes = {...widget.post.likes};
    _initCurrentUserAndProfile();
  }

  Future<void> _initCurrentUserAndProfile() async {
    try {
      final authCubit = context.read<AuthCubit?>();
      currentUser =
          (authCubit?.currentUser ?? FirebaseAuth.instance.currentUser)
              as User?;
    } catch (_) {
      currentUser = FirebaseAuth.instance.currentUser;
    }

    setState(() => isOwnPost = (widget.post.userId == currentUser?.uid));

    try {
      final fetchedUser = await _profileCubit.profileRepo.getProfileUser(
        widget.post.userId,
      );
      if (!mounted) return;
      setState(() {
        postUser = fetchedUser;
        _loadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        postUser = null;
        _loading_profile =
            false; // this line intentionally kept consistent with original variable
      });
    }
  }

  // NOTE: original variable name used _loadingProfile — ensure we use it consistently
  set _loading_profile(bool v) => _loadingProfile = v;

  @override
  void dispose() {
    _commentTextController.dispose();
    super.dispose();
  }

  bool get _isLikedByCurrentUser =>
      currentUser != null && _localLikes.contains(currentUser!.uid);

  void _toggleLike() {
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign in to like posts.')));
      return;
    }

    final uid = currentUser!.uid;
    final previouslyLiked = _localLikes.contains(uid);
    setState(() {
      if (previouslyLiked)
        _localLikes.remove(uid);
      else
        _localLikes.add(uid);
    });

    _postCubit.toggleLikePost(widget.post.id, uid).catchError((_) {
      if (!mounted) return;
      setState(() {
        if (previouslyLiked)
          _localLikes.add(uid);
        else
          _localLikes.remove(uid);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not update like.')));
    });
  }

  void _openAddCommentSheet() {
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign in to comment.')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final media = MediaQuery.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: media.viewInsets.bottom + 12,
            left: 16,
            right: 16,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTextField(
                controller: _commentTextController,
                hintText: 'Write a comment...',
                obscureText: false,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _commentTextController.clear();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => _submitComment(context),
                    child: const Text('Post'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _submitComment(BuildContext sheetContext) {
    final text = _commentTextController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        sheetContext,
      ).showSnackBar(const SnackBar(content: Text('Comment cannot be empty')));
      return;
    }

    final user = currentUser!;
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: user.uid,
      userName: user.displayName ?? user.email ?? 'Unknown',
      text: text,
      timestamp: DateTime.now(),
    );

    _postCubit.addComment(widget.post.id, newComment);
    _commentTextController.clear();
    Navigator.of(sheetContext).pop();
  }

  void _confirmDeletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDeletePressed?.call();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareImage() {
    return CachedNetworkImage(
      imageUrl: widget.post.imageUrl,
      imageBuilder: (context, imageProvider) => AspectRatio(
        aspectRatio: 1 / 1,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
      ),
      placeholder: (context, url) => SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => SizedBox(
        height: 200,
        child: Center(
          child: Icon(
            Icons.broken_image,
            size: 36,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;

    final authorName = (postUser?.name.trim().isNotEmpty == true)
        ? postUser!.name
        : (postUser?.name.trim().isNotEmpty == true)
        ? postUser!.name
        : (widget.post.userName.trim().isNotEmpty
              ? widget.post.userName
              : 'Unknown');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(uid: widget.post.userId),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed('/profile', arguments: widget.post.userId),
                    borderRadius: BorderRadius.circular(32),
                    child: Row(
                      children: [
                        if (_loadingProfile)
                          Container(
                            width: _kAvatarSize,
                            height: _kAvatarSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.04,
                              ),
                            ),
                          )
                        else
                          // Use postUser.profileImageUrl when available, otherwise point to the local fallback.
                          CachedNetworkImage(
                            imageUrl:
                                (postUser?.profileImageUrl != null &&
                                    postUser!.profileImageUrl.trim().isNotEmpty)
                                ? postUser!.profileImageUrl
                                : _localFallbackProfileImage,
                            imageBuilder: (context, imageProvider) => Container(
                              width: _kAvatarSize,
                              height: _kAvatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (_, __) => Container(
                              width: _kAvatarSize,
                              height: _kAvatarSize,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.04,
                                ),
                              ),
                              child: const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => CircleAvatar(
                              radius: _kAvatarSize / 2,
                              child: Icon(Icons.person),
                            ),
                          ),

                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 240),
                              child: Text(
                                authorName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _relativeTime(widget.post.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') _confirmDeletePost();
                    },
                    itemBuilder: (context) => [
                      if (isOwnPost)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        )
                      else
                        const PopupMenuItem(
                          value: 'report',
                          child: Text('Report'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Square image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(0),
            ),
            child: _buildSquareImage(),
          ),

          // Actions & caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<PostCubit, PostState>(
                  builder: (context, state) {
                    final updatedPost = state is PostsLoaded
                        ? state.posts.firstWhere(
                            (p) => p.id == widget.post.id,
                            orElse: () => widget.post,
                          )
                        : widget.post;
                    return Row(
                      children: [
                        IconButton(
                          onPressed: _toggleLike,
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _isLikedByCurrentUser
                                ? const Icon(
                                    Icons.favorite,
                                    key: ValueKey('liked'),
                                  )
                                : const Icon(
                                    Icons.favorite_border,
                                    key: ValueKey('unliked'),
                                  ),
                          ),
                          color: _isLikedByCurrentUser
                              ? Colors.red
                              : Theme.of(context).iconTheme.color,
                          tooltip: 'Like',
                        ),
                        Text(
                          _localLikes.length.toString(),
                          style: TextStyle(
                            color: primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _openAddCommentSheet,
                          icon: Icon(Icons.comment_outlined, color: primary),
                          tooltip: 'Comment',
                        ),
                        Text(
                          updatedPost.comments.length.toString(),
                          style: TextStyle(
                            color: primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            /* TODO: implement share */
                          },
                          icon: Icon(Icons.share_outlined, color: onSurface),
                          tooltip: 'Share',
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 8),
                if (widget.post.text.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      widget.post.text,
                      style: TextStyle(color: onSurface),
                    ),
                  ),
              ],
            ),
          ),

          // Compact comments preview — updated to behave like "your type"
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              if (state is PostsLoaded) {
                final post = state.posts.firstWhere(
                  (p) => p.id == widget.post.id,
                  orElse: () => widget.post,
                );
                if (post.comments.isEmpty) return const SizedBox.shrink();

                final allComments = post.comments;
                final previewCount = 2; // match your desired compact preview
                final commentsToShow = _showAllComments
                    ? allComments
                    : allComments.take(previewCount).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use AnimatedSize to smooth expansion/collapse (keeps layout tidy)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: commentsToShow.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (context, index) => CommentTile(
                          comment: commentsToShow[index],
                          compact: true,
                        ),
                      ),
                    ),

                    // See more / Show less
                    if (allComments.length > previewCount)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          12.0,
                          6.0,
                          12.0,
                          12.0,
                        ),
                        child: GestureDetector(
                          onTap: () => setState(
                            () => _showAllComments = !_showAllComments,
                          ),
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            _showAllComments
                                ? 'Show less'
                                : 'See more comments (${allComments.length - previewCount})',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              } else if (state is PostsLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                );
              } else if (state is PostsError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: Text(state.message)),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}
