//Run App
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/auth/data/firebase_auth_repo.dart';

import 'package:loom/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:loom/features/auth/presentation/cubits/auth_states.dart';
import 'package:loom/features/auth/presentation/pages/auth_page.dart';
import 'package:loom/features/home/presentation/pages/home_page.dart';
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
  final authRepo = FirebaseAuthRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(authRepo: authRepo)..checkAuthentication(),
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
