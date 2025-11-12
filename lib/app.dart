// Run App
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/auth/data/firebase_auth_repo.dart';
import 'package:loom/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:loom/features/auth/presentation/cubits/auth_states.dart';
import 'package:loom/features/auth/presentation/pages/auth_page.dart';
import 'package:loom/features/home/presentation/pages/home_page.dart';
import 'package:loom/features/profile/data/firebase_profile_repo.dart';
import 'package:loom/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:loom/features/storage/data/supabase_storage_repo.dart';
import 'package:loom/themes/light_mode.dart';

/* APP -> Root Level

---------------------------------------------------------------------------------------------
Repositories: fpr the DefaultFirebaseOptions 
  - Firebase

Bloc Provider : for State Management
  - auth
  - profile
  - posts
  - search
  - theme


Check Auth State:
  - Unauthenticated : AuthPage (LoginPage/RegisterPage)
  - Authenticated :  HomePage
  

-----------------------------------------------------------------------------
*/

class MyApp extends StatelessWidget {
  // Auth Repo
  final firebaseAuthRepo = FirebaseAuthRepo();

  // Profile Repo
  final firebaseProfileRepo = FirebaseProfileRepo();

  //storage Repo
  final supabaseStorageRepo = SupabaseStorageRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // auth cubits
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuthentication(),
        ),

        // Profile Cubit
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
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, authState) {
            print(authState);
            // if unauthenticated, show auth page
            if (authState is Unauthenticated) {
              return AuthPage();
            }
            // if authenticated, show home page
            else if (authState is Authenticated) {
              return HomePage();
            }
            // loading state
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },

          // listen for errors
          listener: (context, state) {
            if (state is AuthError) {
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
