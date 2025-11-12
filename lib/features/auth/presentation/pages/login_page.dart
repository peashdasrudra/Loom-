import 'package:flutter/material.dart';
import 'package:loom/features/auth/presentation/components/my_button.dart';
import 'package:loom/features/auth/presentation/components/my_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;
  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  // login button pressed
  void login() {
    // prepare email pw
    final String email = emailController.text;
    final String pw = pwController.text;

    // auth cubit
    final authCubit = context.read<AuthCubit>();

    // ensure that the email and password are not empty
    if (email.isNotEmpty && pw.isNotEmpty) {
      // call login method from auth cubit
      authCubit.login(email, pw);
    } else {
      // show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all required fields")),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ensure Scaffold resizes when keyboard appears
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        // Use LayoutBuilder so we can constrain minHeight to viewport height
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // make room for keyboard so bottom content moves above it
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      // keep the vertical centering when keyboard is closed
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // logo
                        Image.asset('assets/images/app_banner.png', height: 80),

                        const SizedBox(height: 50),

                        Center(
                          child: Lottie.network(
                            'https://lottie.host/a5abeac1-fdc0-4a31-a418-688f47094b96/wzepsMUj7x.json',
                            height: 150,
                            width: 150,
                          ),
                        ),

                        const SizedBox(height: 50),

                        // welcome back msg
                        Text(
                          "Welcome back, you've been missed!",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // email textfield
                        MyTextField(
                          controller: emailController,
                          hintText: "Email",
                          obscureText: false,
                        ),

                        const SizedBox(height: 15),

                        // password textfield
                        MyTextField(
                          controller: pwController,
                          hintText: "Password",
                          obscureText: true,
                        ),

                        const SizedBox(height: 30),

                        // login button
                        MyButton(onTap: login, text: "Login"),

                        const SizedBox(height: 20),

                        // not a member? register now
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Not a member? ",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            GestureDetector(
                              onTap: widget.togglePages,
                              child: Text(
                                "Register now",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // optional spacer to ensure bottom spacing when fully expanded
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
