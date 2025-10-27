import 'package:flutter/material.dart';
import 'package:loom/features/auth/presentation/components/my_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();

  class _LoginPageState extends State<LoginPage> {
    // text editing controllers
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _pwController = TextEditingController();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              //logo
              Icon(
                Icons.lock_open_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            
            const SizedBox(height: 50),

              // welcome back msg
              Text(
                'Welcome back you \'ve been missed!',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              // email textfield
            MyTextField(controller: _emailController, hintText: 'Email', obscureText: false,)

              // pw textfield

              // login button

              // not a member? register now
            ],
          ),
        ),
      ),
    );
  }
}
