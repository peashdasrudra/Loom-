import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/post/domain/entities/post.dart';
import 'package:loom/features/post/presentation/cubits/post_cubit.dart';
import 'package:loom/features/profile/domain/entities/profile_user.dart';
import 'package:loom/features/profile/presentation/cubits/profile_cubit.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  // cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  // post user
  ProfileUser? postUser;

  // current user
  User? currentUser;

  // on startup
  @override
  void initState() {
    super.initState();

    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    // Read firebase auth user directly. This avoids casting your app-specific user
    // object (like AppUser) into Firebase's `User` which caused the TypeError.
    currentUser = FirebaseAuth.instance.currentUser;
    isOwnPost = (widget.post.userId == currentUser?.uid);
  }

  Future<void> fetchPostUser() async {
    // Use the underlying repo to retrieve the user object directly
    final fetchedUser = await profileCubit.profileRepo.getProfileUser(
      widget.post.userId,
    );
    if (fetchedUser != null) {
      // Guard with mounted to avoid setState after dispose
      if (!mounted) return;
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  /*

  LIKES

  */

  // user tapped like button
  void toggleLikePost() {
    if (currentUser == null) return; // guard against null user

    // current like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    // optimistically like and update uid
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid); // unlike
      } else {
        widget.post.likes.add(currentUser!.uid); // like
      }
    });

    // update likes
    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((
      error,
    ) {
      // if there is an error, revert back to original values
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid); // revert like
        } else {
          widget.post.likes.remove(currentUser!.uid); // revert unlike
        }
      });
    });
  }

  // show options for Deletion
  void showOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post?"),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),

          // delete button
          TextButton(
            onPressed: () {
              widget.onDeletePressed?.call();
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  String _prettyTimestamp(DateTime t) {
    // simple, compact readable timestamp (no extra package)
    final local = t.toLocal();
    final date =
        "${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}";
    final time =
        "${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
    return "$date $time";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // top section : profile pic / name / delete button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                // profile pic or placeholder
                if (postUser?.profileImageUrl != null &&
                    postUser!.profileImageUrl.trim().isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: postUser!.profileImageUrl,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (_, __) => Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.onSurface.withOpacity(0.04),
                      ),
                      child: const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => CircleAvatar(
                      radius: 22,
                      child: const Icon(Icons.person),
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.colorScheme.onSurface.withOpacity(
                      0.04,
                    ),
                    child: const Icon(Icons.person),
                  ),

                const SizedBox(width: 10),

                // name & subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _prettyTimestamp(widget.post.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // delete button (only for owner)
                if (isOwnPost)
                  IconButton(
                    onPressed: () => showOptions(context),
                    icon: Icon(Icons.more_vert, color: onSurface),
                    tooltip: 'Options',
                  ),
              ],
            ),
          ),

          // image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.zero,
              bottom: Radius.circular(12),
            ),
            child: CachedNetworkImage(
              imageUrl: widget.post.imageUrl,
              height: 430,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => SizedBox(
                height: 430,
                child: Center(child: CircularProgressIndicator(color: primary)),
              ),
              errorWidget: (context, url, error) => SizedBox(
                height: 430,
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    color: theme.colorScheme.error,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),

          // actions row (like, comment, share) + caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // action buttons
                Row(
                  children: [
                    Row(
                      children: [
                        // like button (now IconButton for material feedback)
                        IconButton(
                          onPressed: toggleLikePost,
                          icon: Icon(
                            widget.post.likes.contains(currentUser?.uid ?? '')
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          color:
                              widget.post.likes.contains(currentUser?.uid ?? '')
                              ? Colors.red
                              : Colors.black, // <<< Black when not liked
                          tooltip: 'Like',
                        ),

                        // <<< Same spacing as comment
                        Text(
                          widget.post.likes.length.toString(),
                          style: TextStyle(
                            color: Colors
                                .black, // <<< Match icon color for consistency
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 5),

                    // comment button
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.comment_outlined, color: onSurface),
                    ),
                    const SizedBox(width: 1),
                    Text("0", style: TextStyle(color: onSurface)),

                    const Spacer(),

                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.share_outlined, color: onSurface),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // caption / text
                if (widget.post.text.trim().isNotEmpty)
                  Text(widget.post.text, style: TextStyle(color: onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
