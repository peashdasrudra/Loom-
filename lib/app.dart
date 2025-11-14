// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loom/features/auth/data/firebase_auth_repo.dart';
import 'package:loom/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:loom/features/auth/presentation/cubits/auth_states.dart'
    as app_auth;
import 'package:loom/features/auth/presentation/pages/auth_page.dart';
import 'package:loom/features/home/presentation/pages/home_page.dart';
import 'package:loom/features/post/data/firebase_post_repo.dart';
import 'package:loom/features/post/presentation/cubits/post_cubit.dart';
import 'package:loom/features/profile/data/firebase_profile_repo.dart';
import 'package:loom/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:loom/features/storage/data/supabase_storage_repo.dart';
import 'package:loom/themes/light_mode.dart';

/// App: Root-level widget that wires repositories, cubits and the top-level MaterialApp.
class App extends StatelessWidget {
  // Repositories (kept as instance fields for easy testing/override later)
  final FirebaseAuthRepo firebaseAuthRepo = FirebaseAuthRepo();
  final FirebaseProfileRepo firebaseProfileRepo = FirebaseProfileRepo();
  final SupabaseStorageRepo supabaseStorageRepo = SupabaseStorageRepo();
  final FirebasePostRepo firebasePostRepo = FirebasePostRepo();

  App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth cubit: checks authentication on creation
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuthentication(),
        ),

        // Profile cubit (depends on profile & storage repos)
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileRepo: firebaseProfileRepo,
            storageRepo: supabaseStorageRepo,
          ),
        ),

        // Post cubit
        BlocProvider<PostCubit>(
          create: (context) => PostCubit(
            postRepo: firebasePostRepo,
            storageRepo: supabaseStorageRepo,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        home: BlocConsumer<AuthCubit, app_auth.AuthState>(
          builder: (context, authState) {
            // Unauthenticated -> show AuthPage
            if (authState is app_auth.Unauthenticated) {
              return AuthPage();
            }
            // Authenticated -> show HomePage
            else if (authState is app_auth.Authenticated) {
              return HomePage();
            }

            // Loading / unknown -> show progress
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
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
