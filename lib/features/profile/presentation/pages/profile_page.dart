// lib/features/profile/presentation/pages/profile_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/profile/presentation/pages/followers_page.dart';

import 'package:loom/features/auth/presentation/cubits/auth_cubit.dart';

import 'package:loom/features/post/presentation/components/post_tile.dart';
import 'package:loom/features/post/presentation/cubits/post_cubit.dart';
import 'package:loom/features/post/presentation/cubits/post_states.dart';
import 'package:loom/features/profile/domain/entities/profile_user.dart';

import 'package:loom/features/profile/presentation/components/bio_box.dart';
import 'package:loom/features/profile/presentation/components/follow_button.dart';
import 'package:loom/features/profile/presentation/components/profile_stats.dart';
import 'package:loom/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:loom/features/profile/presentation/cubits/profile_states.dart';
import 'package:loom/features/profile/presentation/pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final ProfileCubit _profileCubit = context.read<ProfileCubit>();
  late final AuthCubit _authCubit = context.read<AuthCubit>();

  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  late final Animation<double> _scaleAnim = CurvedAnimation(
    parent: _animController,
    curve: Curves.easeOutBack,
  );

  @override
  void initState() {
    super.initState();
    _profileCubit.fetchProfileUser(widget.uid);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onFollowPressed(ProfileUser profileUser) {
    final currentUser = _authCubit.currentUser;
    if (currentUser == null) return;

    final isFollowing = profileUser.followers.contains(currentUser.uid);

    // Optimistic UI update
    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(currentUser.uid);
      } else {
        profileUser.followers.add(currentUser.uid);
      }
    });

    // Perform actual follow toggle
    _profileCubit.toggleFollow(currentUser.uid, profileUser.uid).catchError((
      _,
    ) {
      // Revert on error
      setState(() {
        if (isFollowing) {
          profileUser.followers.add(currentUser.uid);
        } else {
          profileUser.followers.remove(currentUser.uid);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = _authCubit.currentUser;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return _loadingScaffold();
        }

        if (state is! ProfileLoaded) {
          return _errorScaffold();
        }

        final user = state.profileUser;

        final bool isOwnProfile =
            currentUser != null && currentUser.uid == user.uid;

        final bool isFollowing =
            currentUser != null && user.followers.contains(currentUser.uid);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            title: const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              if (isOwnProfile)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfilePage(user: user),
                    ),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name & email
                  Center(
                    child: Column(
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: theme.colorScheme.primary.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Profile image
                  Center(
                    child: GestureDetector(
                      onTap: isOwnProfile
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfilePage(user: user),
                              ),
                            )
                          : null,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Hero(
                              tag: 'profile_image_${user.uid}',
                              child: Container(
                                height: 160,
                                width: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                      color: Colors.black.withOpacity(0.08),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: CachedNetworkImage(
                                  imageUrl: user.profileImageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      Container(color: Colors.black12),
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.person, size: 72),
                                ),
                              ),
                            ),
                            if (isOwnProfile)
                              Positioned(
                                right: 0,
                                bottom: -6,
                                child: Material(
                                  color: Colors.black.withOpacity(0.45),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(999),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditProfilePage(user: user),
                                      ),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Stats
                  ProfileStats(
                    posts: context.select<PostCubit, int>(
                      (cubit) => cubit.state is PostsLoaded
                          ? (cubit.state as PostsLoaded).posts
                                .where((p) => p.userId == user.uid)
                                .length
                          : 0,
                    ),
                    followers: user.followers.length,
                    following: user.following.length,
                    onFollowersTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FollowersPage(
                            ids: user.followers,
                            title: 'Followers',
                          ),
                        ),
                      );
                    },
                    onFollowingTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FollowersPage(
                            ids: user.following,
                            title: 'Following',
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Follow button
                  if (!isOwnProfile && currentUser != null)
                    FollowButton(
                      isFollowing: isFollowing,
                      onPressed: () => _onFollowPressed(user),
                    ),

                  const SizedBox(height: 30),

                  // Bio card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Bio',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          BioBox(text: user.bio),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Posts',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),

                  const SizedBox(height: 8),

                  BlocBuilder<PostCubit, PostState>(
                    builder: (context, postState) {
                      if (postState is PostsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (postState is! PostsLoaded) {
                        return const Center(child: Text('No posts'));
                      }

                      final userPosts = postState.posts
                          .where((p) => p.userId == user.uid)
                          .toList();

                      if (userPosts.isEmpty) {
                        return const Center(child: Text('No posts yet'));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userPosts.length,
                        itemBuilder: (_, index) {
                          final post = userPosts[index];
                          return PostTile(
                            post: post,
                            onDeletePressed: isOwnProfile
                                ? () => context.read<PostCubit>().deletePost(
                                    post.id,
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Scaffold _loadingScaffold() =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));

  Scaffold _errorScaffold() =>
      const Scaffold(body: Center(child: Text('Unable to load profile')));
}
