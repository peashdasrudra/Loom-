import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: theme.primary,
        ),
        filled: true,
        fillColor: theme.secondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        // border when unselected
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.tertiary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),

        // border when selected
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.primary,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
