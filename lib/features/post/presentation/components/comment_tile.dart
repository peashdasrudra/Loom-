// lib/features/post/presentation/widgets/comment_tile_final.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/auth/domain/entities/app_user.dart';
import 'package:loom/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:loom/features/post/domain/entities/comment.dart';
import 'package:loom/features/post/presentation/cubits/post_cubit.dart';
import 'package:loom/features/profile/domain/entities/profile_user.dart';
import 'package:loom/features/profile/presentation/cubits/profile_cubit.dart';

/// comment_tile_final.dart
/// Final polished CommentTile for dense comment lists.
/// - Compact avatar (28px)
/// - Tight paddings and smaller typography
/// - Name on first line, comment text below
/// - Delete/options button aligned to top-right of tile
///
/// NOTE: If you want to use the uploaded screenshot as a local placeholder,
/// the path available in this environment is:
///   /mnt/data/Screenshot_20251121-230328.loom.png
/// (Convert or serve it as an asset/file URL in your environment if needed.)

class CommentTile extends StatefulWidget {
  final Comment comment;

  /// If true, will show a compact layout suitable for dense lists.
  final bool compact;

  const CommentTile({super.key, required this.comment, this.compact = true});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  static const double _avatarSize = 28.0;
  ProfileUser? _commentUser;
  AppUser? _currentUser;
  bool _isOwnComment = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // Prefer app-level AuthCubit for consistency; fall back gracefully if not provided.
    try {
      final authCubit = context.read<AuthCubit?>();
      _currentUser = authCubit?.currentUser;
    } catch (_) {
      _currentUser = null;
    }

    _isOwnComment =
        _currentUser != null && widget.comment.userId == _currentUser!.uid;
    _fetchCommentUser();
  }

  Future<void> _fetchCommentUser() async {
    try {
      final profileCubit = context.read<ProfileCubit>();
      final user = await profileCubit.profileRepo.getProfileUser(
        widget.comment.userId,
      );
      if (!mounted) return;
      setState(() {
        _commentUser = user;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _commentUser = null;
        _loading = false;
      });
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete comment?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<PostCubit>().deleteComment(
                widget.comment.postId,
                widget.comment.id,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
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

  String _safeTrim(String? s) => s == null ? '' : s.trim();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Safe selection of display name: prefer profile.name, fallback to comment.userName
    final profileName = _safeTrim(_commentUser?.name);
    final displayName = profileName.isNotEmpty
        ? profileName
        : (_safeTrim(widget.comment.userName).isNotEmpty
              ? _safeTrim(widget.comment.userName)
              : 'Unknown');

    // Reduced outer padding to make list dense
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // aligns avatar and tile top edges
        children: [
          // Avatar
          Semantics(
            label: '$displayName profile picture',
            child: GestureDetector(
              onTap: () {
                if (widget.comment.userId.isNotEmpty) {
                  Navigator.of(
                    context,
                  ).pushNamed('/profile', arguments: widget.comment.userId);
                }
              },
              child: _loading
                  ? Container(
                      width: _avatarSize,
                      height: _avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.onSurface.withOpacity(0.04),
                      ),
                    )
                  : (_commentUser?.profileImageUrl != null &&
                        _commentUser!.profileImageUrl.trim().isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: _commentUser!.profileImageUrl,
                      imageBuilder: (context, imageProvider) => Container(
                        width: _avatarSize,
                        height: _avatarSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (_, __) => Container(
                        width: _avatarSize,
                        height: _avatarSize,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.onSurface.withOpacity(0.04),
                        ),
                        child: const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => CircleAvatar(
                        radius: _avatarSize / 2,
                        backgroundColor: theme.colorScheme.onSurface
                            .withOpacity(0.04),
                        child: const Icon(Icons.person, size: 14),
                      ),
                    )
                  : CircleAvatar(
                      radius: _avatarSize / 2,
                      backgroundColor: theme.colorScheme.onSurface.withOpacity(
                        0.04,
                      ),
                      child: const Icon(Icons.person, size: 14),
                    ),
            ),
          ),

          const SizedBox(width: 8),

          // Main body: container with name (top row) and comment text below.
          // We place the options button outside the container so it sits aligned top-right.
          Expanded(
            child: Container(
              // tightened inner padding for density
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 10.0,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + timestamp in one row. The delete icon lives outside this container,
                  // aligned in the parent Row's trailing area (see below).
                  Row(
                    children: [
                      // Name
                      Expanded(
                        child: Text(
                          displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            // Slightly smaller for compactness
                            fontSize: theme.textTheme.bodySmall?.fontSize,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Timestamp (right aligned within this row)
                      Text(
                        _relativeTime(widget.comment.timestamp.toLocal()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.65,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Comment text below name (multi-line, wrapped)
                  Text(
                    widget.comment.text,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Options for comment owner: aligned to top-right of the tile.
          // Because the parent Row has crossAxisAlignment.start, this IconButton
          // will be top-aligned next to the container.
          if (_isOwnComment)
            Padding(
              padding: const EdgeInsets.only(left: 6.0, top: 2.0),
              child: IconButton(
                onPressed: _confirmDelete,
                icon: Icon(
                  Icons.more_horiz,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                tooltip: 'Comment options',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
        ],
      ),
    );
  }
}
