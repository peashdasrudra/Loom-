// lib/features/profile/presentation/pages/profile_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/auth/domain/entities/app_user.dart';
import 'package:loom/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:loom/features/post/presentation/components/post_tile.dart';
import 'package:loom/features/post/presentation/cubits/post_cubit.dart';
import 'package:loom/features/post/presentation/cubits/post_states.dart';
import 'package:loom/features/profile/presentation/components/bio_box.dart';
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
  // Cubits
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  // Current User (from auth)
  late AppUser? currentUser = authCubit.currentUser;

  // Animation controller for scale transition
  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  late final Animation<double> _scaleAnim = CurvedAnimation(
    parent: _animController,
    curve: Curves.easeOutBack,
  );

  // Posts
  int postsCount = 0;

  @override
  void initState() {
    super.initState();
    // fetch profile for the requested uid
    profileCubit.fetchProfileUser(widget.uid);

    // start animation after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  TextStyle _titleStyle(BuildContext c) => const TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w800,
    fontSize: 24,
    letterSpacing: 0.2,
  );

  TextStyle _subtitleStyle(BuildContext c) => TextStyle(
    color: Theme.of(c).colorScheme.primary.withOpacity(0.85),
    fontSize: 14,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // loaded profile
        if (state is ProfileLoaded) {
          final user = state.profileUser;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              centerTitle: true,
              foregroundColor: theme.colorScheme.primary,
              title: const Text(
                "Profile",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(user: user),
                    ),
                  ),
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),

            // use scroll view so smaller screens / long bios work well
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // top: name + email centered
                    Center(
                      child: Column(
                        children: [
                          Text(user.name, style: _titleStyle(context)),
                          const SizedBox(height: 6),
                          Text(
                            user.email,
                            style: _subtitleStyle(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // animated profile image with hero and camera icon
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(user: user),
                          ),
                        ),
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
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary.withOpacity(
                                          0.06,
                                        ),
                                        theme.colorScheme.primary.withOpacity(
                                          0.02,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: CachedNetworkImage(
                                    // cache-buster so newly uploaded images show immediately
                                    imageUrl:
                                        "${user.profileImageUrl}?v=${DateTime.now().millisecondsSinceEpoch}",
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(0.03),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: theme.colorScheme.onBackground
                                              .withOpacity(0.03),
                                          child: Icon(
                                            Icons.person,
                                            size: 72,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                  ),
                                ),
                              ),

                              // bottom-right transparent camera icon (keeps same functionality)
                              Positioned(
                                right: 0,
                                bottom: -6,
                                child: Material(
                                  color: Colors.black.withOpacity(0.45),
                                  elevation: 2,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(999),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditProfilePage(user: user),
                                      ),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
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

                    const SizedBox(height: 30),

                    // Info card (bio + small stats placeholder)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                      margin: EdgeInsets.zero,
                      color: theme.colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Bio label and content
                            Row(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Bio',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // use your existing BioBox widget for the bio content
                            BioBox(text: user.bio),

                            const SizedBox(height: 14),

                            // subtle divider to separate bio from other info (keeps layout same)
                            Divider(
                              color: theme.colorScheme.onBackground.withOpacity(
                                0.06,
                              ),
                              height: 1,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Posts header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Posts',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        // small edit quick-link to posts (keeps original edit behavior unchanged)
                        IconButton(
                          onPressed: () {
                            // kept intentionally light — matches previous behavior
                          },
                          icon: Icon(
                            Icons.grid_view,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),

                    // placeholder area for posts list (your home page shows full posts; keep this short)
                    Container(
                      height: 80,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onBackground.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'User posts appear in Home screen list',
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // list of post from the user
                    BlocBuilder<PostCubit, PostState>(
                      builder: (context, state) {
                        // posts loaded
                        if (state is PostsLoaded) {
                          // filter posts by user id
                          final userPosts = state.posts
                              .where((post) => post.userId == widget.uid)
                              .toList();

                          postsCount = userPosts.length;

                          return ListView.builder(
                            itemCount: postsCount,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              // get individual posts
                              final post = userPosts[index];

                              // return as post tile ui
                              return PostTile(
                                post: post,
                                onDeletePressed: () => context
                                    .read<PostCubit>()
                                    .deletePost(post.id),
                              );
                            },
                          );
                        }
                        // posts Loading
                        else if (state is PostsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          // <-- FIXED: previously this branch constructed a Center but did not return it.
                          return const Center(child: Text("No Posts... "));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        // Loading state
        else if (state is ProfileLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Profile",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              foregroundColor: Theme.of(context).colorScheme.primary,
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        // Error / initial state
        else {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Profile",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              foregroundColor: Theme.of(context).colorScheme.primary,
              centerTitle: true,
            ),
            body: const Center(child: Text('Unable to load profile')),
          );
        }
      },
    );
  }
}
