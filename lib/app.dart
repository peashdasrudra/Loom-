// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loom/features/auth/data/firebase_auth_repo.dart';
import 'package:loom/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:loom/features/auth/presentation/cubits/auth_states.dart'
    as app_auth;
import 'package:loom/features/auth/presentation/pages/auth_page.dart';
import 'package:loom/features/home/presentation/components/main_shell.dart';
import 'package:loom/features/home/presentation/components/my_drawer.dart';

import 'package:loom/features/home/presentation/pages/home_page.dart';
import 'package:loom/features/post/presentation/pages/upload_post_page.dart';
import 'package:loom/features/profile/presentation/pages/profile_page.dart';

import 'package:loom/features/post/data/firebase_post_repo.dart';
import 'package:loom/features/post/presentation/cubits/post_cubit.dart';

import 'package:loom/features/profile/data/firebase_profile_repo.dart';
import 'package:loom/features/profile/presentation/cubits/profile_cubit.dart';

import 'package:loom/features/storage/data/supabase_storage_repo.dart';

import 'package:loom/themes/light_mode.dart';

///
/// App: Root widget that wires repositories, cubits and MaterialApp.
///
class App extends StatelessWidget {
  // ──────────────────────────────────────────────────────────────────────────
  // Repositories (kept as instance fields for easy unit testing / override)
  // ──────────────────────────────────────────────────────────────────────────
  final FirebaseAuthRepo firebaseAuthRepo = FirebaseAuthRepo();
  final FirebaseProfileRepo firebaseProfileRepo = FirebaseProfileRepo();
  final SupabaseStorageRepo supabaseStorageRepo = SupabaseStorageRepo();
  final FirebasePostRepo firebasePostRepo = FirebasePostRepo();

  App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth Cubit → Handles login state, refreshes, token checks, etc.
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuthentication(),
        ),

        // Profile Cubit → Profile details + picture uploads
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileRepo: firebaseProfileRepo,
            storageRepo: supabaseStorageRepo,
          ),
        ),

        // Post Cubit → Creating, uploading, deleting, fetching posts
        BlocProvider<PostCubit>(
          create: (context) => PostCubit(
            postRepo: firebasePostRepo,
            storageRepo: supabaseStorageRepo,
          ),
        ),
      ],

      // ──────────────────────────────────────────────────────────────────────
      // Main MaterialApp
      // ──────────────────────────────────────────────────────────────────────
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,

        // Register routes so pushNamed('/profile', ...) works across the app.
        // This keeps navigation centralized and avoids missing route exceptions.
        routes: {
          // Keep the home route mapping (home is handled by the AuthBloc consumer below).
          // We do not use '/' here to override the auth-driven home; the "home" property
          // is driven by the BlocConsumer. We only provide named routes used across the app.
          '/profile': (context) {
            // Resolve uid from the RouteSettings arguments if provided,
            // otherwise fall back to the currently authenticated user's uid.
            final settings = ModalRoute.of(context)?.settings;
            final args = settings?.arguments;
            String uidFromArgs = '';
            if (args is String && args.isNotEmpty) {
              uidFromArgs = args;
            } else {
              try {
                final authCubit = context.read<AuthCubit?>();
                uidFromArgs = authCubit?.currentUser?.uid ?? '';
              } catch (_) {
                uidFromArgs = '';
              }
            }

            // ProfilePage expects a uid param (used in your MainShell as well).
            // If uid is empty, the ProfilePage should handle the empty-case gracefully,
            // or you can adapt to your app's expected behavior.
            return ProfilePage(uid: uidFromArgs);
          },
        },

        // Optional: handle unknown routes gracefully instead of throwing.
        onUnknownRoute: (settings) {
          // fallback to a safe page (HomePage)
          return MaterialPageRoute(builder: (_) => const HomePage());
        },

        // Auth state decides whether to show Login or Main App UI
        home: BlocConsumer<AuthCubit, app_auth.AuthState>(
          builder: (context, authState) {
            // ────────────────────────────────────────────────────────────────
            // NOT LOGGED IN → Go to Auth Page
            // ────────────────────────────────────────────────────────────────
            if (authState is app_auth.Unauthenticated) {
              return AuthPage();
            }
            // ────────────────────────────────────────────────────────────────
            // LOGGED IN → Load MainShell with animated bottom navigation
            // ────────────────────────────────────────────────────────────────
            else if (authState is app_auth.Authenticated) {
              // use the logged-in user's id for the profile page route
              final userId = context.read<AuthCubit>().currentUser!.uid;

              return MainShell(
                pages: [
                  const HomePage(), // Bottom nav index 0 -> Home
                  const UploadPostPage(), // Bottom nav index 1 -> Create
                  ProfilePage(uid: userId), // Bottom nav index 2 -> Profile
                ],
                // Pass your app drawer into the shell so the shell can detect
                // when the drawer opens and hide the bottom nav accordingly.
                drawer: const MyDrawer(),
              );
            }

            // ────────────────────────────────────────────────────────────────
            // UNKNOWN / LOADING → Progress Indicator
            // ────────────────────────────────────────────────────────────────
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },

          // Show errors from Auth Cubit as snackbars
          listener: (context, state) {
            if (state is app_auth.AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ),
    );
  }
}
