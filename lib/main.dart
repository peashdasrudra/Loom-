// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loom/config/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/auth/data/firebase_auth_repo.dart';
import 'package:loom/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:loom/features/auth/presentation/cubits/auth_states.dart'
    as app_auth;
import 'package:loom/features/auth/presentation/pages/auth_page.dart';
import 'package:loom/features/home/presentation/pages/home_page.dart';
import 'package:loom/features/profile/data/firebase_profile_repo.dart';
import 'package:loom/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:loom/features/storage/data/supabase_storage_repo.dart';
import 'package:loom/themes/light_mode.dart';

Future<void> main() async {
  // Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Supabase initialization
  await Supabase.initialize(
    url: 'https://ccxgqsdseuebtosbzczq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNjeGdxc2RzZXVlYnRvc2J6Y3pxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4ODc5ODEsImV4cCI6MjA3ODQ2Mzk4MX0.L0-mWct5DUucp-FZSjPyZkBJOqSHAwKu8JNhDWbG6Xs',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Auth Repo
  final firebaseAuthRepo = FirebaseAuthRepo();

  // Profile Repo
  final firebaseProfileRepo = FirebaseProfileRepo();

  // Storage Repo
  final supabaseStorageRepo = SupabaseStorageRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // auth cubit
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuthentication(),
        ),

        // profile cubit
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileRepo: firebaseProfileRepo,
            storageRepo: supabaseStorageRepo,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        // NOTE: use the aliased app_auth.AuthState to avoid conflict with Supabase's AuthState
        home: BlocConsumer<AuthCubit, app_auth.AuthState>(
          builder: (context, authState) {
            // if unauthenticated, show auth page
            if (authState is app_auth.Unauthenticated) {
              return AuthPage();
            }
            // if authenticated, show home page
            else if (authState is app_auth.Authenticated) {
              return HomePage();
            }
            // loading
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
