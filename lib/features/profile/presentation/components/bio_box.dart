import 'package:flutter/material.dart';

class BioBox extends StatelessWidget {
  final String text;
  const BioBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),

        // soft shadow for card-like look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],

        // thin border to separate from background
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.08),
        ),
      ),

      child: Center(
        child: Text(
          text.isNotEmpty ? text : 'No bio available...',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 15.5,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
