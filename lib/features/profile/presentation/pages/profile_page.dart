// lib/features/profile/presentation/pages/profile_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/auth/domain/entities/app_user.dart';
import 'package:loom/features/auth/presentation/cubits/auth_cubit.dart';
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

  // Current User
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

  @override
  void initState() {
    super.initState();
    profileCubit.fetchProfileUser(widget.uid);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final user = state.profileUser;
          return Scaffold(
            appBar: AppBar(
              title: Text(user.name),
              foregroundColor: Theme.of(context).colorScheme.primary,
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(user: user),
                    ),
                  ),
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
            body: Column(
              children: [
                const SizedBox(height: 12),

                // email
                Text(
                  user.email,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 20),

                // Animated profile picture with Hero transition and camera icon
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
                              height: 200,
                              width: 200,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: CachedNetworkImage(
                                imageUrl:
                                    "${user.profileImageUrl}?v=${DateTime.now().millisecondsSinceEpoch}",
                                // Instead of circular loading spinner — show faded color or blank
                                placeholder: (context, url) => Container(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary.withOpacity(0.3),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.person,
                                  size: 72,
                                  color: Theme.of(context).colorScheme.primary,
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

                          // Bottom-right transparent camera icon
                          Positioned(
                            right: 15,
                            bottom: 10,
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
                                    size: 20,
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

                const SizedBox(height: 15),

                // Bio label (centered)
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Center(
                    child: Text(
                      'Bio:',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Bio
                BioBox(text: user.bio),

                // Posts label
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, top: 25),
                  child: Row(
                    children: [
                      Text(
                        'Posts:',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        // Loading state
        else if (state is ProfileLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(currentUser?.name ?? 'Profile'),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        // Error / initial state
        else {
          return Scaffold(
            appBar: AppBar(
              title: Text(currentUser?.name ?? 'Profile'),
              centerTitle: true,
            ),
            body: const Center(child: Text('Unable to load profile')),
          );
        }
      },
    );
  }
}
