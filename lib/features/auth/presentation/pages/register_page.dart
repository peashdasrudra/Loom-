import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loom/features/auth/presentation/components/my_button.dart';
import 'package:loom/features/auth/presentation/components/my_text_field.dart';
import 'package:loom/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:lottie/lottie.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();

  // register button pressed
  void register() {
    // prepare name, email, pw, confirm pw
    final String name = nameController.text;
    final String email = emailController.text;
    final String pw = pwController.text;
    final String confirmPw = confirmPwController.text;

    // auth cubit
    final authCubit = context.read<AuthCubit>();

    // ensure that the email and password are not empty
    if (name.isNotEmpty &&
        email.isNotEmpty &&
        pw.isNotEmpty &&
        confirmPw.isNotEmpty) {
      if (pw == confirmPw) {
        // call register method from auth cubit
        authCubit.register(name, email, pw);
      } else {
        // show snackbar
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      }
    } else {
      // show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all required fields")),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ensure Scaffold resizes when keyboard appears
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // logo
                        Image.asset('assets/images/Logo_Lockup.jpg', height: 80),

                        const SizedBox(height: 50),

                        Center(
                          child: Lottie.network(
                            'https://lottie.host/a5abeac1-fdc0-4a31-a418-688f47094b96/wzepsMUj7x.json',
                            height: 120,
                            width: 150,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // create account msg
                        Text(
                          "Let's create an account for you!",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // name textfield
                        MyTextField(
                          controller: nameController,
                          hintText: "Name",
                          obscureText: false,
                        ),

                        const SizedBox(height: 15),

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

                        const SizedBox(height: 15),

                        // confirm password textfield
                        MyTextField(
                          controller: confirmPwController,
                          hintText: "Confirm Password",
                          obscureText: true,
                        ),

                        const SizedBox(height: 30),

                        // register button
                        MyButton(onTap: register, text: "Register"),

                        const SizedBox(height: 20),

                        // alr a member? login now
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already a member? ",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),

                            GestureDetector(
                              onTap: widget.togglePages,
                              child: Text(
                                "Login now",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
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
